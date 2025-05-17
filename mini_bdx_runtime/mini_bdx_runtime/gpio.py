import platform
import logging

# Try to import different GPIO implementations
try:
    import RPi.GPIO as RPiGPIO

    HAS_RPI_GPIO = True
except ImportError:
    HAS_RPI_GPIO = False

try:
    import gpiod

    HAS_GPIOD = True
except ImportError:
    HAS_GPIOD = False


class GPIO:
    """Platform-agnostic GPIO interface that works with different GPIO implementations."""

    # GPIO modes
    BCM = 11
    BOARD = 10
    OUT = 0
    IN = 1
    HIGH = 1
    LOW = 0
    PUD_UP = 2
    PUD_DOWN = 1

    def __init__(self):
        self._gpio = None
        self._mode = None
        self._setup_pins = {}
        self._pwm_channels = {}

        # Try to initialize the appropriate GPIO implementation
        if HAS_RPI_GPIO:
            self._gpio = RPiGPIO
            logging.info("Using RPi.GPIO implementation")
        elif HAS_GPIOD:
            self._gpio = gpiod
            logging.info("Using gpiod implementation")
        else:
            logging.warning("No GPIO implementation found. Using mock GPIO.")
            self._gpio = MockGPIO()

    def setmode(self, mode):
        """Set the GPIO mode (BCM or BOARD)."""
        self._mode = mode
        if hasattr(self._gpio, "setmode"):
            self._gpio.setmode(mode)

    def setwarnings(self, flag):
        """Enable or disable warnings."""
        if hasattr(self._gpio, "setwarnings"):
            self._gpio.setwarnings(flag)

    def setup(self, channel, mode, pull_up_down=None):
        """Set up a GPIO channel."""
        self._setup_pins[channel] = (mode, pull_up_down)
        if hasattr(self._gpio, "setup"):
            if pull_up_down is not None:
                self._gpio.setup(channel, mode, pull_up_down=pull_up_down)
            else:
                self._gpio.setup(channel, mode)

    def output(self, channel, value):
        """Set the output state of a GPIO channel."""
        if hasattr(self._gpio, "output"):
            self._gpio.output(channel, value)

    def input(self, channel):
        """Read the input state of a GPIO channel."""
        if hasattr(self._gpio, "input"):
            return self._gpio.input(channel)
        return self.LOW

    def PWM(self, channel, frequency):
        """Create a PWM instance."""
        if hasattr(self._gpio, "PWM"):
            pwm = self._gpio.PWM(channel, frequency)
            self._pwm_channels[channel] = pwm
            return pwm
        return MockPWM()

    def cleanup(self):
        """Clean up GPIO resources."""
        if hasattr(self._gpio, "cleanup"):
            self._gpio.cleanup()
        self._setup_pins.clear()
        self._pwm_channels.clear()


class MockGPIO:
    """Mock GPIO implementation for testing and development."""

    def setmode(self, mode):
        pass

    def setwarnings(self, flag):
        pass

    def setup(self, channel, mode, pull_up_down=None):
        pass

    def output(self, channel, value):
        pass

    def input(self, channel):
        return 0

    def cleanup(self):
        pass


class MockPWM:
    """Mock PWM implementation for testing and development."""

    def start(self, dutycycle):
        pass

    def ChangeDutyCycle(self, dutycycle):
        pass

    def stop(self):
        pass


# Create a global GPIO instance
gpio = GPIO()