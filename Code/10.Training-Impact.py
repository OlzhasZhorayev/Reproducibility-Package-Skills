
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# Load Temp and Figures directory paths defined in Paths.py
from Paths import TEMP_DIR, FIG_DIR

# Read data from the Excel file
file_path = TEMP_DIR / "Pooled_Estimates_Training.xlsx"

# ── Sheet 1: Overall Effect ───────────────────────────────────────────────────────
df1 = pd.read_excel(file_path, sheet_name='Sheet1')

df1['Subgroup'] = df1.apply(lambda row: f"{row['Subgroup']} (N = {int(row['N'])})", 
                            axis=1)
df1['CI_lower'] = df1['Theta'] - 1.96 * df1['SE']
df1['CI_upper'] = df1['Theta'] + 1.96 * df1['SE']
df1['y_pos'] = np.arange(len(df1)) * 1.5 + 1.0
df1['source'] = 'sheet1'

# ── Sheet 2: Heterogeneity Effects ────────────────────────────────────────────────
df2 = pd.read_excel(file_path, sheet_name='Sheet2')

# Define desired subgroup order within selected groups
order_map = {
    "Big Five": [
        "Conscientiousness", "Disagreeableness", "Emotional stability",
        "Extraversion", "Openness", "Multiple"
    ],
    "Grade level": [
        "Primary or less", "Secondary", "Post-secondary"
    ],
    "Instructor": [
        "Teaching staff", "Other"
    ]
}

df2["Subgroup_base"] = df2["Subgroup"].str.replace(r"\s*\(N =.*\)", "", regex=True)
df2["order"] = df2.groupby("Group")["Subgroup_base"].transform(
    lambda x: x.map({v: i for i, v in enumerate(order_map.get(x.name, x.unique()))})
)

group_order = [
    "Big Five", "Grade level", "Setting", 
    "Instructor", "Targeting", "Technology"
]
df2["Group"] = pd.Categorical(df2["Group"], categories=group_order, ordered=True)
df2 = df2.sort_values(by=["Group", "order"]).reset_index(drop=True)

df2['Subgroup'] = df2.apply(lambda row: f"{row['Subgroup']} (N = {int(row['N'])})", 
                            axis=1)
df2['CI_lower'] = df2['Theta'] - 1.96 * df2['SE']
df2['CI_upper'] = df2['Theta'] + 1.96 * df2['SE']
df2['source'] = 'sheet2'

# ── Assign y positions: Sheet1 first (small y = top), Sheet2 below with a gap 
GAP = 2.0  # Adjust to desired gap
sheet2_y_start = df1['y_pos'].max() + GAP
df2['y_pos'] = np.arange(len(df2)) * 1.5 + sheet2_y_start

# ── Assign colors consistently across both sheets ─────────────────────────────────
all_groups = list(df1['Group'].unique()) + [
    g for g in df2['Group'].unique() if g not in df1['Group'].unique()
]
cmap = plt.get_cmap('tab10')
color_map = {group: cmap(i) for i, group in enumerate(all_groups)}

df1['color'] = df1['Group'].map(color_map)
df2['color'] = df2['Group'].astype(str).map(color_map)

# ── Figure setup ──────────────────────────────────────────────────────────────────
total_rows = len(df1) + len(df2)
fig_height = total_rows * 0.7 + 3.0

fig, ax = plt.subplots(figsize=(20, fig_height))
plt.rcParams["font.family"] = "Arial"

# ── Plot Sheet1 rows ──────────────────────────────────────────────────────────────
for _, row in df1.iterrows():
    ax.errorbar(
        row['Theta'], row['y_pos'],
        xerr=[[row['Theta'] - row['CI_lower']], [row['CI_upper'] - row['Theta']]],
        fmt='s', capsize=4, markersize=6, color=row['color']
    )
    ax.text(row['Theta'], row['y_pos'] + 0.4, f"{row['Theta']:.3f}",
            ha='center', va='center', fontsize=14, color='black')

# ── Plot Sheet2 rows ──────────────────────────────────────────────────────────────
for _, row in df2.iterrows():
    ax.errorbar(
        row['Theta'], row['y_pos'],
        xerr=[[row['Theta'] - row['CI_lower']], [row['CI_upper'] - row['Theta']]],
        fmt='s', capsize=4, markersize=6, color=row['color']
    )
    ax.text(row['Theta'], row['y_pos'] - 0.4, f"{row['Theta']:.3f}",
            ha='center', va='center', fontsize=14, color='black')

# ── Vertical reference line at zero ───────────────────────────────────────────────
ax.axvline(x=0, color='black', linestyle='--', linewidth=1)

# ── Y-axis ticks and labels (combined) ────────────────────────────────────────────
combined_y = list(df1['y_pos']) + list(df2['y_pos'])
combined_labels = list(df1['Subgroup']) + list(df2['Subgroup'])
ax.set_yticks(combined_y)
ax.set_yticklabels(combined_labels, fontsize=14)
ax.set_xlabel('Effect size', fontsize=16, fontweight='bold')
ax.tick_params(axis='x', labelsize=14)

# ── Invert axis FIRST, then set limits in (large, small) order ────────────────────
# Passing (max, min) after invert_yaxis ensures Sheet1 (small y) stays at TOP
# and Sheet2 (large y) stays at BOTTOM, preventing the axis from being flipped back
ax.invert_yaxis()
ax.set_ylim(df2['y_pos'].max() + 2.0, df1['y_pos'].min() - 2.5)

# ── Spines ────────────────────────────────────────────────────────────────────────
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

# ── Group labels (bold, left of y-axis) ───────────────────────────────────────────
GROUP_LABEL_X = -0.55

for group in df1['Group'].unique():
    group_data = df1[df1['Group'] == group]
    mid_pos = (group_data['y_pos'].min() + group_data['y_pos'].max()) / 2
    ax.text(GROUP_LABEL_X, mid_pos, group,
            verticalalignment='center', horizontalalignment='center',
            color='black', fontsize=16, rotation=0, fontweight='bold')

for group in df2['Group'].unique():
    group_data = df2[df2['Group'] == group]
    mid_pos = (group_data['y_pos'].min() + group_data['y_pos'].max()) / 2
    ax.text(GROUP_LABEL_X, mid_pos, str(group),
            verticalalignment='center', horizontalalignment='center',
            color='black', fontsize=16, rotation=0, fontweight='bold')

# ── Separator dashed lines within Sheet1 groups ───────────────────────────────────
last_sheet1_group = df1['Group'].unique()[-1]
for group in df1['Group'].unique():
    if group == last_sheet1_group:
        continue  # Skip the bottom separator, 
                  # as Sheet2 already draws one at the top of its first group
    group_data = df1[df1['Group'] == group]
    upper_bound = group_data['y_pos'].max() + 1.5
    ax.hlines(y=upper_bound, xmin=-0.02, xmax=1.0,
              color='gray', linestyle='--', linewidth=0.5)

# ── Separator dashed lines within Sheet2 groups ───────────────────────────────────
for group in df2['Group'].unique():
    group_data = df2[df2['Group'] == group]
    lower_bound = group_data['y_pos'].min() - 0.9
    ax.hlines(y=lower_bound, xmin=-0.02, xmax=1.0,
              color='gray', linestyle='--', linewidth=0.5)

# ── Layout and save ───────────────────────────────────────────────────────────────
plt.subplots_adjust(left=0.45, right=0.9, top=0.95, bottom=0.1)
output_file = FIG_DIR / "Figure4.TrainingImpact.png"
plt.savefig(output_file, dpi=300, bbox_inches='tight')
plt.close(fig)

