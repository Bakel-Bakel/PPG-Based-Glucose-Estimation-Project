# **README: PPG-Based Glucose Estimation Project**  

## **📌 Overview**  
This repository contains a complete workflow for processing **Photoplethysmography (PPG) signals** to estimate **blood glucose levels**. The dataset includes raw PPG signals, corresponding glucose level labels, and extracted features for **machine learning (ML) and deep learning (CNN) models**.  

The project covers the following steps:  
✅ **Data Visualization** – Understanding the dataset and visualizing raw signals. 

✅ **Linking PPG Signals to Glucose Levels** – Mapping each PPG signal to its respective glucose level. 

✅ **Cleaning the Data** – Applying a **Finite Impulse Response (FIR) filter** to remove noise. 

✅ **Plotting Raw vs. Cleaned Signals** – Comparing signals before and after filtering.

✅ **Feature Extraction** – Extracting time-domain, frequency-domain, and morphological features. 

✅ **Dataset Preparation for ML/CNN** – Creating structured `.csv` and `.mat` files for model training. 

---

## **📂 File Structure**  

```
📦 PPG_Glucose_Estimation
 ┣ 📂 PPG_Dataset
 ┃ ┣ 📂 RawData              # Original PPG signals (.mat)
 ┃ ┣ 📂 Labels               # Corresponding glucose level files (.mat)
 ┃ ┣ 📂 Figures              # Pre-plotted PPG visualizations (.jpg)
 ┃ ┣ 📂 CleanedData          # Noise-filtered PPG signals (.mat)
 ┃ ┣ 📂 ML                   # Extracted features for ML (.csv & .mat)
 ┃ ┣ 📜 Total.mat            # Consolidated label data
 ┃ ┗ 📜 README.md            # Project Documentation
 ┣ 📜 visualize_data.m       # Script for visualizing raw PPG signals
 ┣ 📜 link_data.m            # Links PPG signals with glucose levels
 ┣ 📜 clean_data.m           # Applies FIR filtering to PPG signals
 ┣ 📜 plot_signals.m         # Plots raw vs. cleaned PPG signals
 ┣ 📜 extract_features.m     # Extracts features for ML/CNN
 ┣ 📜 plot_all_trials.m      # Plots all trials for a subject
 ┗ 📜 run_all.m              # Runs all scripts sequentially
```

---

## **📊 1. Data Visualization**  

### **🔹 What We Did**  
- Explored the dataset and its structure.
- Plotted individual **PPG signals** to analyze signal variations.
- Used **`visualize_data.m`** to display signals.  

### **🛠 How to Run**  
```matlab
visualize_data;
```
This script loads and plots **random PPG signals** from the dataset.  

---

## **🔗 2. Linking Raw PPG Data to Glucose Levels**  

### **🔹 What We Did**  
- Extracted **PPG signals** from the `RawData` folder.
- Mapped them to their corresponding **glucose levels** from the `Labels` folder.
- Created a **structured dataset** linking each signal to its glucose level.

### **🛠 How to Run**  
```matlab
link_data;
```
This script generates **`PPG_Glucose_Dataset.mat` and `PPG_Glucose_Dataset.csv`**, storing PPG signals with their glucose levels.

---

## **🛠 3. Cleaning the Data (Noise Removal)**  

### **🔹 What We Did**  
- Applied a **Finite Impulse Response (FIR) low-pass filter** to remove noise.
- Used MATLAB’s `filtfilt()` to **preserve the phase** of the signal.
- Stored cleaned signals in the `CleanedData` folder.

### **🛠 How to Run**  
```matlab
clean_data;
```
This script processes all raw signals and saves the cleaned versions.

---

## **📉 4. Plotting Raw vs. Cleaned Signals**  

### **🔹 What We Did**  
- Compared **original (raw) and cleaned PPG signals** to visualize improvements.
- Displayed signals **before and after noise filtering**.

### **🛠 How to Run**  
To plot a **specific trial**:
```matlab
plotPPGComparison('01', '0001');
```
To plot **all trials for a subject**:
```matlab
plotAllTrialsForSubject('02');
```
These scripts generate side-by-side plots of raw and cleaned signals.

---

## **📈 5. Feature Extraction**  

### **🔹 Features Extracted and Why**  
We extracted three types of features:

### **⏳ Time-Domain Features**
| Feature | Description |
|---------|------------|
| **Mean** | Average signal value |
| **STD (Standard Deviation)** | Signal variability |
| **RMS (Root Mean Square)** | Energy of the signal |
| **Skewness** | Asymmetry of the waveform |
| **Kurtosis** | Peak sharpness |
| **Peak-to-Peak** | Difference between highest and lowest points |

**Why?** These features capture the **magnitude and distribution** of the PPG signals.

---

### **📡 Frequency-Domain Features**
| Feature | Description |
|---------|------------|
| **Peak Frequency** | Dominant frequency in the signal |
| **Spectral Entropy** | Complexity of frequency distribution |

**Why?** Frequency features help analyze **underlying periodicity** and **autonomic regulation**.

---

### **📊 Morphological Features**
| Feature | Description |
|---------|------------|
| **Number of Peaks** | Total detected pulses |
| **Average Peak Height** | Average systolic peak height |
| **Peak-to-Peak Interval** | Time between successive peaks |

**Why?** These features help capture **pulse wave characteristics**, which correlate with **glucose fluctuations**.

---

### **🛠 How to Run Feature Extraction**  
```matlab
extract_features;
```
This script:
- Extracts all **time-domain, frequency-domain, and morphological features**.
- Includes **glucose levels**.
- Saves results in:
  - `PPG_Features.mat` (MATLAB table).
  - `PPG_Features.csv` (For ML/CNN).

---

## **🚀 6. Running the Entire Pipeline**  
Instead of running each script manually, execute the entire pipeline using:
```matlab
run_all;
```
This script sequentially:
1. **Links PPG signals with glucose levels**.
2. **Cleans the data using FIR filtering**.
3. **Extracts all relevant features**.
4. **Stores everything for ML/CNN training**.

---

## **📂 How to Use the Data for Machine Learning**  

### **🛠 Importing Data in Python (Pandas)**
```python
import pandas as pd
df = pd.read_csv("PPG_Dataset/ML/PPG_Features.csv")
df.head()
```
This loads the **pre-processed dataset** for training machine learning models.

---

