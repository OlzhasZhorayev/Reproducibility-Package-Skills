
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# Load Temp and Figures directory paths defined in Paths.py
from Paths import TEMP_DIR, FIG_DIR

# Read data from the Excel file
file_path = TEMP_DIR / "Pooled_Estimates_Training.xlsx"

# Specify the sheet name
sheet1 = 'Sheet1'

# Read the specific sheet
df = pd.read_excel(file_path, sheet_name=sheet1)   # Overall effect 

# Modify the 'Subgroup' column to include N values
df['Subgroup'] = df.apply(lambda row: f"{row['Subgroup']} (N = {int(row['N'])})", axis=1)

# Calculate the confidence intervals
df['CI_lower'] = df['Theta'] - 1.96 * df['SE']
df['CI_upper'] = df['Theta'] + 1.96 * df['SE']

# Adjust the space between y-axis ticks for better compactness
df['y_pos'] = np.arange(len(df)) * 1.5 + 1.0 # Added +1.0 to move up from x-axis

# Assign colors to each group
cmap = plt.get_cmap('tab10')
unique_groups = df['Group'].unique()
color_map = {group: cmap(i) for i, group in enumerate(unique_groups)}
df['color'] = df['Group'].map(color_map)

# Adjust figure height based on the number of rows
fig_height = len(df) * 0.7 + 1.5 # Height (0.7 per row) + added extra height (1.5)

# Plot
fig, ax = plt.subplots(figsize=(20, fig_height))  # Adjust figure height

# Set the font to Arial, fallback to default if not found
plt.rcParams["font.family"] = "Arial"

# Error bars for each subgroup
for i, row in df.iterrows():
    ax.errorbar(row['Theta'], row['y_pos'], xerr=[[row['Theta'] - row['CI_lower']], [row['CI_upper'] - row['Theta']]], 
                fmt='s', capsize=4, markersize=6, color=row['color'])  # 's' makes the marker a square
    # Add the effect size (Theta) as a text annotation **above** each error bar
    ax.text(row['Theta'], row['y_pos'] + 0.4, f"{row['Theta']:.3f}",  # Changed from -0.4 to +0.4 to put the effect label above
            ha='center', va='center', fontsize=14, color='black') 

# Add a vertical line at zero
ax.axvline(x=0, color='black', linestyle='--', linewidth=1)

# Customize axis ticks and labels
ax.set_yticks(df['y_pos'])
ax.set_yticklabels(df['Subgroup'], fontsize=14)
ax.invert_yaxis()
ax.set_xlabel('Effect size', fontsize=16, fontweight='bold')
ax.tick_params(axis='x', labelsize=14)

# Remove the top and right spines (the "box" effect)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

# Add vertical group labels to the side of the plot and move group labels to the left
for group in df['Group'].unique():
    group_data = df[df['Group'] == group]
    mid_pos = (group_data['y_pos'].min() + group_data['y_pos'].max()) / 2  # Calculate a middle position for the group
    ax.text(-0.55, mid_pos, group,  # Adjust the Group label position to the left: -0.30 for sheet1
            verticalalignment='center', horizontalalignment='center', 
            color='black', fontsize=16, rotation=0, fontweight='bold')  

# Add horizontal grey dashed lines between groups
for group in unique_groups:
    group_data = df[df['Group'] == group]
    upper_bound = group_data['y_pos'].max() + 1.5  # Above (adjusted from lower_bound to upper_bound and from min to max) 
    ax.hlines(y=upper_bound, xmin=-0.02, xmax=1.0, color='gray', linestyle='--', linewidth=0.5) 
    # Adjust xmax = 1.0 for Sheet1

# Adjust the y-axis limits for the new y position (to move estimate dot and CI line up)
ax.set_ylim(-1, df['y_pos'].max() + 2)  # Add buffer at top and bottom

# Adjust layout and save the plot
plt.subplots_adjust(left=0.45, right=0.9, top=0.95, bottom=0.1)
output_file = FIG_DIR / "Figure4.TrainingImpact.png"
plt.savefig(output_file, dpi=300, bbox_inches='tight')  # Change dpi (dots per inch) for the resolution of the image
plt.close(fig)  # Clear the figure from memory
