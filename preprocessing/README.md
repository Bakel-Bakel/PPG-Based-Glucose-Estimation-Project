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


## **📊 1. Data Visualization**  

### **🔹 What I Did**  
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

### **🔹 What I Did**  
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
Here’s a clean, professional `README.md` file tailored for your **PPG Signal Feature Extraction** project that includes everything from objectives to instructions:

---

## 🧱 Feature Extraction Steps

The pipeline includes the following steps:

### 1. **Raw Data Loading**
Loads `.mat` files from `RawData/` and corresponding glucose labels from `Labels/`.

### 2. **Preprocessing**
- FIR Filtering
- Smoothing with Hanning window
- Band-pass filtering (0.5 – 20 Hz)
- Subsampling (D = 5)
- Z-score normalization

### 3. **Feature Extraction**
Extracts **18 physiological and signal features**:
- Time/Frequency Domain: `Mean`, `STD`, `RMS`, `Skewness`, `Kurtosis`, `PeakToPeak`, etc.
- Entropy-based: `ApproxEntropy`, `SampleEntropy`
- Fractal-based: `DFA`
- Wavelet Features: `Energy`, `Entropy`

### 4. **Export**
- Creates a table: `ExtractedFeaturesTable.mat`
- Saves a CSV: `ExtractedFeatures.csv` in `/ML`

---

## 🚀 How to Run

### Step 1: Open MATLAB  
Make sure your working directory is set to the root of this repo.

### Step 2: Run the pipeline

```matlab
PPG_FeaturePipeline
```

This executes all processes: filtering, normalization, feature extraction, visualization, and export.

### Step 3: (Optional) Visualize Output  
You can preview the extracted features with:

```matlab
visualizeExtractedFeatures(featureTable);
```



