from gpiozero import LED
from time import sleep

green = LED(17)
yellow = LED(19)
red = LED(21)

while True:
    red.on(); yellow.off(); green.off()
    sleep(1)
    red.off(); yellow.on(); green.off()
    sleep(1)
    red.off(); yellow.off(); green.on()
    sleep(1)
