#!/usr/bin/env python3
import board
import digitalio
import numpy as np

LEFT_FOOT_PIN = board.D22
RIGHT_FOOT_PIN = board.D27

class FeetContacts:
    def __init__(self):
        self.left_foot = digitalio.DigitalInOut(LEFT_FOOT_PIN)
        self.left_foot.direction = digitalio.Direction.INPUT
        self.left_foot.pull = digitalio.Pull.UP

        self.right_foot = digitalio.DigitalInOut(RIGHT_FOOT_PIN)
        self.right_foot.direction = digitalio.Direction.INPUT
        self.right_foot.pull = digitalio.Pull.UP

    def get(self):
        left = not self.left_foot.value
        right = not self.right_foot.value
        return np.array([left, right])

    def __del__(self):
        self.left_foot.deinit()
        self.right_foot.deinit()

if __name__ == "__main__":
    import time

    feet_contacts = FeetContacts()
    while True:
        print(feet_contacts.get())
        time.sleep(0.05)