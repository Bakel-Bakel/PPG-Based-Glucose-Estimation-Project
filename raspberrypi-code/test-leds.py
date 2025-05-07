import RPi.GPIO as GPIO
import time

# GPIO setup
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

# Assign GPIO pins
green = 17
yellow = 19
red = 21

# Setup each as output
GPIO.setup(green, GPIO.OUT)
GPIO.setup(yellow, GPIO.OUT)
GPIO.setup(red, GPIO.OUT)

# Helper function to turn all off
def all_off():
    GPIO.output(green, GPIO.LOW)
    GPIO.output(yellow, GPIO.LOW)
    GPIO.output(red, GPIO.LOW)

try:
    while True:
        # Pattern 1: Traffic Light Sequence
        GPIO.output(green, GPIO.HIGH)
        time.sleep(1)
        GPIO.output(green, GPIO.LOW)
        GPIO.output(yellow, GPIO.HIGH)
        time.sleep(0.5)
        GPIO.output(yellow, GPIO.LOW)
        GPIO.output(red, GPIO.HIGH)
        time.sleep(1)
        GPIO.output(red, GPIO.LOW)

        # Pattern 2: Ping-pong effect
        for i in range(2):
            GPIO.output(green, GPIO.HIGH)
            time.sleep(0.3)
            GPIO.output(green, GPIO.LOW)
            GPIO.output(yellow, GPIO.HIGH)
            time.sleep(0.3)
            GPIO.output(yellow, GPIO.LOW)
            GPIO.output(red, GPIO.HIGH)
            time.sleep(0.3)
            GPIO.output(red, GPIO.LOW)

            GPIO.output(yellow, GPIO.HIGH)
            time.sleep(0.3)
            GPIO.output(yellow, GPIO.LOW)

        # Pattern 3: All blink together
        for i in range(3):
            GPIO.output(green, GPIO.HIGH)
            GPIO.output(yellow, GPIO.HIGH)
            GPIO.output(red, GPIO.HIGH)
            time.sleep(0.2)
            all_off()
            time.sleep(0.2)

except KeyboardInterrupt:
    all_off()
    GPIO.cleanup()
