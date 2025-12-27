
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# Read data from the Excel file
file_path = '/Users/Admin/OneDrive - George Mason University - O365 Production/Documents/GMU/Dr Kugler/Skills/Reproducibility Package/Temp/Pooled_Estimates_RE_Main.xlsx'
# Specify the sheet name
sheet1 = 'Sheet1'

# Read the specific sheet
df = pd.read_excel(file_path, sheet_name=sheet1)    

# Modify the 'Subgroup' column to include N values
df['Subgroup'] = df.apply(lambda row: f"{row['Subgroup']} (N = {int(row['N'])})", axis=1)

# Calculate the confidence intervals
df['CI_lower'] = df['Theta'] - 1.96 * df['SE']
df['CI_upper'] = df['Theta'] + 1.96 * df['SE']

# Adjust the space between y-axis ticks for better compactness
df['y_pos'] = np.arange(len(df)) * 1.5  # Adjust the spacing based on row count

# Assign colors to each group
cmap = plt.get_cmap('tab10')
unique_groups = df['Group'].unique()
color_map = {group: cmap(i) for i, group in enumerate(unique_groups)}
df['color'] = df['Group'].map(color_map)

# Adjust figure height based on the number of rows
fig_height = len(df) * 0.7  # Calculate height (0.7 or 1.1 height per row)

# Plot
fig, ax = plt.subplots(figsize=(20, fig_height))  # Adjust figure height

# Set the font to Arial, fallback to default if not found
plt.rcParams["font.family"] = "Arial"

# Error bars for each subgroup
for i, row in df.iterrows():
    ax.errorbar(row['Theta'], row['y_pos'], xerr=[[row['Theta'] - row['CI_lower']], [row['CI_upper'] - row['Theta']]], 
                fmt='s', capsize=4, markersize=6, color=row['color'])  # 's' makes the marker a square
    # Add the effect size (Theta) as a text annotation **above** each error bar
    ax.text(row['Theta'], row['y_pos'] - 0.4, f"{row['Theta']:.3f}",  # Adjust to 0.4 or more
            ha='center', va='center', fontsize=14, color='black') 

# Add a vertical line at zero
ax.axvline(x=0, color='black', linestyle='--', linewidth=1)

# Customize axis ticks and labels
ax.set_yticks(df['y_pos'])
ax.set_yticklabels(df['Subgroup'], fontsize=14)
ax.invert_yaxis()
ax.set_xlabel('Effect size', fontsize=16, fontweight='bold')
ax.tick_params(axis='x', labelsize=14)
ax.set_xlim(-0.02, 0.12)  # Set the minimum and maximum of the x-axis

# Remove the top and right spines (the "box" effect)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

# Add vertical group labels to the side of the plot and move group labels to the left
for group in df['Group'].unique():
    group_data = df[df['Group'] == group]
    mid_pos = (group_data['y_pos'].min() + group_data['y_pos'].max()) / 2  # Calculate a middle position for the group
    ax.text(-0.09, mid_pos, group,  # Adjust the Group label position to the left: -0.09
            verticalalignment='center', horizontalalignment='center', 
            color='black', fontsize=16, rotation=0, fontweight='bold')  

# Add horizontal grey dashed lines between groups
for group in unique_groups:
    group_data = df[df['Group'] == group]
    lower_bound = group_data['y_pos'].min() - 0.9  # Slightly below the group
    ax.hlines(y=lower_bound, xmin=-0.02, xmax=0.12, color='gray', linestyle='--', linewidth=0.5) 
    # Adjust xmax = 0.12

# Adjust layout and save the plot
plt.subplots_adjust(left=0.45, right=0.9, top=0.95, bottom=0.1)
output_file = '/Users/Admin/OneDrive - George Mason University - O365 Production/Documents/GMU/Dr Kugler/Skills/Reproducibility Package/Figures/FigureA7.WageReturnsREMain.png'
plt.savefig(output_file, dpi=300, bbox_inches='tight')  # Change dpi (dots per inch) for the resolution of the image
plt.close(fig)  # Clear the figure from memory
