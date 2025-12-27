
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# Load Temp and Figures directory paths defined in paths.py
from paths import TEMP_DIR, FIG_DIR

# Read data
#file_path = '/Users/Admin/OneDrive - George Mason University - O365 Production/Documents/GMU/Dr Kugler/Skills/Reproducibility Package/Temp/Pooled_Estimates_Training.xlsx'
file_path = TEMP_DIR / "Pooled_Estimates_Training.xlsx"

df = pd.read_excel(file_path)

# Compute confidence intervals if needed
df['CI_lower'] = df['Theta'] - 1.96 * df['SE']
df['CI_upper'] = df['Theta'] + 1.96 * df['SE']

# Extract Overall effect row
df_overall = df.loc[df['Subgroup'].str.contains('Overall effect', case=False)].iloc[0]
theta_overall = df_overall['Theta']
ci_lower_overall = df_overall['CI_lower']
ci_upper_overall = df_overall['CI_upper']

# Build effect sizes / errors with Big Five on top
effect_sizes = [theta_overall]  # Can add more, if any, after comma
errors = [
    [theta_overall - ci_lower_overall], # Can add more, if any, after comma
    [ci_upper_overall - theta_overall]  # Can add more, if any, after comma
]

# Get the N values from the Excel column named 'N'
n_overall = int(df_overall['N'])

# Label strings for Y-axis
labels = [
    f"Overall effect (N = {n_overall})" # Can include additional f"" after comma, if needed
]

# Assign y-position(s) 
y_positions = [0.07] # Can add more, if any, after comma

fig, ax = plt.subplots(figsize=(10, 2.5)) # width and height

# Plot error bars with squares and horizontal “edges”
ax.errorbar(
    effect_sizes,
    y_positions,
    xerr=errors,
    fmt='s',                 # square markers
    color='steelblue',
    capsize=4,               # length of error bar endcaps
    elinewidth=2,            # thickness of the horizontal lines
    markersize=5             # smaller squares
)

# Add numerical labels above each square
for x_val, y_val in zip(effect_sizes, y_positions):
    ax.text(
        x_val,
        y_val + 0.01,
        f"{x_val:.3f}",
        ha='center',
        va='bottom',
        fontsize=10,
        color='black'
    )

# Use the labels with (N = …) on the Y-axis
ax.set_yticks(y_positions)
ax.set_yticklabels(labels)

# Make the x-axis title bold
ax.set_xlabel("Effect size", fontweight='bold')

# Remove unneeded spines
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.grid(False)

# Constrain vertical and horizontal limits
ax.set_ylim(0, 0.15)
ax.set_xlim(left=0)

plt.tight_layout()
plt.subplots_adjust(left=0.25, bottom=0.15, top=0.9, right=0.95)

# Save the plot
#output_file = '/Users/Admin/OneDrive - George Mason University - O365 Production/Documents/GMU/Dr Kugler/Skills/Reproducibility Package/Figures/Figure4.TrainingImpact.png'
output_file = FIG_DIR / "Figure4.TrainingImpact.png"
plt.savefig(output_file, dpi=300, bbox_inches='tight')  # Change dpi (dots per inch) for the resolution of the image

# Show the plot
plt.show() # Only after plt.savefig() to save properly
plt.close(fig)  # Clear the figure from memory
