from gpiozero import LED
from time import sleep

green = LED(11)   # GPIO11 (Pin 23)
yellow = LED(10)  # GPIO10 (Pin 19)
red = LED(9)      # GPIO9  (Pin 21)

while True:
    # Red on
    red.on(); yellow.off(); green.off()
    sleep(0.5)

    # Yellow on
    red.off(); yellow.on(); green.off()
    sleep(0.5)

    # Green on
    red.off(); yellow.off(); green.on()
    sleep(0.5)

    # Blink all together
    for _ in range(3):
        red.on(); yellow.on(); green.on()
        sleep(0.2)
        red.off(); yellow.off(); green.off()
        sleep(0.2)
