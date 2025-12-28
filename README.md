
# Reproducibility Package  
**Evidence Synthesis on Socio-Emotional Skill Returns and Training Impacts**

---

## 1. Overview

This reproducibility package contains the data-processing, analysis, and visualization code used in the paper:

**Evidence Synthesis on Socio-Emotional Skill Returns and Training Impacts**

### Collaborators
- **Diego Angel-Urdinola**¹  
- **Maurice Kugler**²  
- **Narae Lee**¹  
- **Angelo Santos**¹²  
- **Olzhas Zhorayev**¹²  

¹ World Bank  
² George Mason University  

### Software
- **Python**
- **Stata**

### Objective
The objective of this project is to study:
1. **Labor market returns to socio-emotional skills (SES)**, and  
2. **The effectiveness of SES training programs**,  

using a systematic evidence synthesis and meta-analytic framework.

The package is designed to be run end-to-end using a **Python master script**, which calls Stata in batch mode to process the data and then generates all figures using Python.

---

## 2. Data Availability

### Data Availability Statement
- ☐ All data are publicly available.  
- ☑ **Some data cannot be made publicly available.**  
- ☐ No data can be made publicly available.  

### Data Files Used
This package relies on two cleaned data files:

1. **`Data_clean.dta`**  
   - Content: Harmonized wage-return estimates for socio-emotional and cognitive skills  
   - Format: Stata `.dta`  
   - Used for: Wage-returns meta-analysis  

2. **`Training_data_clean.xlsx`**  
   - Content: Harmonized meta-analysis results on socio-emotional skill training impacts  
   - Format: Excel `.xlsx`  
   - Used for: Training-impact meta-meta-analysis  

**Data Access Note**  
All data used in this project are **temporarily embargoed by the authors**. The data are **included in a private GitHub repository for authorized replicators**. Public release is expected in the future.

For detailed information on data collection please refer to the **Database Construction** section and **Appendix A** of the paper.

---

## 3. Instructions for Replicators

### Prerequisites
To replicate the results, users must:
1. Obtain access to the required data files (`Data_clean.dta`, `Training_data_clean.xlsx`)  
2. Place the files in the **`Data/`** folder  
3. Install the required software (see Section 5)

### Running the Package
This project uses **Python as the master runner**.

**Step 1.** Open a terminal in the project root directory  

**Step 2.** Set the path to your local Stata executable (example for Windows):

```powershell
$env:STATA_EXE="C:\Program Files\Stata18\StataMP-64.exe"
