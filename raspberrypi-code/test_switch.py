from gpiozero import LED, Button
from signal import pause

# === GPIO SETUP ===
green_led = LED(9)       # Green LED on GPIO9
start_switch = Button(17, pull_up=True)  # Switch on GPIO17, with internal pull-up

# === Behavior ===
def led_on():
    green_led.on()
    print("Switch pressed → Green LED ON")

def led_off():
    green_led.off()
    print("Switch released → Green LED OFF")

# === Bind Events ===
start_switch.when_pressed = led_on
start_switch.when_released = led_off

# === Keep script running ===
print("Waiting for switch press...")
pause()
