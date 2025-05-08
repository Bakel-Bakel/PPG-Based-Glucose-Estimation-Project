import os
import numpy as np
import pandas as pd
from scipy.io import loadmat
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv1D, MaxPooling1D, Flatten, Dense, Dropout
from tensorflow.keras.callbacks import EarlyStopping

# === CONFIGURATION ===
SIGNAL_FOLDER = "../PPG_Dataset/RawData"
LABEL_FILE = "../PPG_Dataset/rawdata-glucose.xlsx"
WINDOW_SIZE = 200
STEP_SIZE = 200  # non-overlapping

# === LOAD LABELS ===
df = pd.read_excel(LABEL_FILE)
df.set_index("Trial_ID", inplace=True)

# === EXTRACT DATA WINDOWS ===
X = []
y = []

for file in os.listdir(SIGNAL_FOLDER):
    if file.endswith(".mat") and file in df.index:
        mat = loadmat(os.path.join(SIGNAL_FOLDER, file))
        signal = mat["signal"].flatten().astype(np.float32)

        glucose = df.loc[file, "Glucose"]
        for start in range(0, len(signal) - WINDOW_SIZE + 1, STEP_SIZE):
            window = signal[start:start + WINDOW_SIZE]
            X.append(window)
            y.append(glucose)

X = np.array(X)
y = np.array(y)

# === NORMALIZE AND RESHAPE ===
scaler = MinMaxScaler()
X = scaler.fit_transform(X)
X = X.reshape(X.shape[0], X.shape[1], 1)

# === TRAIN-TEST SPLIT ===
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# === BUILD CNN MODEL ===
model = Sequential([
    Conv1D(32, kernel_size=5, activation='relu', input_shape=(WINDOW_SIZE, 1)),
    MaxPooling1D(pool_size=2),
    Conv1D(64, kernel_size=5, activation='relu'),
    MaxPooling1D(pool_size=2),
    Flatten(),
    Dense(64, activation='relu'),
    Dropout(0.3),
    Dense(1)  # Regression output
])

model.compile(optimizer='adam', loss='mse', metrics=['mae'])

# === TRAIN MODEL ===
early_stop = EarlyStopping(patience=5, restore_best_weights=True)
model.fit(X_train, y_train, epochs=50, batch_size=32, validation_split=0.2, callbacks=[early_stop])

# === EVALUATE MODEL ===
loss, mae = model.evaluate(X_test, y_test)
print(f"Test MSE: {loss:.2f}, MAE: {mae:.2f}")

# === SAVE MODEL ===
model.save("cnn_glucose_regressor.h5")

# === EXPORT TO TFLITE ===
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()
with open("cnn_glucose_regressor.tflite", "wb") as f:
    f.write(tflite_model)

print("Model exported as cnn_glucose_regressor.tflite")
