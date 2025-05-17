# Non-Invasive Glucose Estimation Project

A non-invasive, edge-deployed glucose monitoring system built using a Raspberry Pi, a photoplethysmography (PPG) sensor, a machine learning model, and GPIO-based feedback components. This project estimates blood glucose levels using PPG signals, displays real-time waveforms on an OLED screen, and provides automatic email alerts and LED indicators based on the prediction.

---

## 📌 Project Summary

This project implements a complete pipeline for real-time glucose level estimation using a CNN model deployed on a Raspberry Pi. The system collects analog PPG signals, processes the data through a TensorFlow Lite model, classifies the glucose level into healthy, pre-diabetic, or diabetic ranges, and responds through:

- 🔴🟡🟢 **LED indicators** (via GPIO)
- 📧 **Email alerts** to multiple recipients
- 📺 **Live waveform display** on an SSD1306 OLED screen
- 🎛️ **Push-button control** to trigger the reading on demand

The system is designed to run **automatically at startup**, making it ideal for standalone, remote, or medical monitoring applications.

[Preprocessing](preprocessing/README.md)

[Machine Learning and Training](ML/)


---

## 🧠 Features

- **Real-time PPG signal collection** using ADS1015 ADC
- **Live waveform rendering** on OLED (128x64)
- **Glucose level prediction** using a TFLite-optimized CNN model
- **GPIO LED feedback system**:
  - Green: Healthy
  - Yellow: Pre-diabetic
  - Red: Diabetic
- **Push-button interface** to initiate reading on demand
- **Automatic email notifications** to multiple addresses
- **Boot-time autostart** using `systemd` service

---

## 🛠️ Technologies & Hardware

- **Raspberry Pi** (tested on Pi 5)
- **PPG Sensor** connected via **ADS1015 ADC**
- **OLED SSD1306 Display** (I2C, 128x64)
- **GPIO LEDs** and **Tactile Push Button**
- **Python 3**, `gpiozero`, `numpy`, `tflite-runtime`, `PIL`, `smtplib`, `sklearn`, `Adafruit` libraries
- **TensorFlow Lite CNN** for glucose regression

---

## 🚀 How to Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Bakel-Bakel/PPG-Based-Glucose-Estimation-Project.git
   cd PPG-Based-Glucose-Estimation-Project/


2. **Install dependencies**:

   ```bash
   pip install -r requirements.txt
   ```

3. **Make script executable**:

   ```bash
   chmod +x raspberrypi-code/ppg_cnn.py
   ```

4. **Run manually**:

   ```bash
   python3 raspberrypi-code/ppg_cnn.py
   ```



---



---

## 📬 Contact & Credits

Built with ❤️ by Bakel Bakel

---

## 📄 License

This project is licensed under the MIT License. Feel free to use, modify, and build upon it.


