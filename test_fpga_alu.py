import RPi.GPIO as GPIO
import time
import random

# Define pins (BCM) exactly according to our wiring table
# Lists are ordered from LSB (index 0) to MSB (last index)
PINS_A   = [17, 27, 22, 10]
PINS_B   = [9, 11, 5, 6]
PINS_SEL = [13, 19, 26]
PINS_Y   = [21, 20, 16, 12]

def setup():
    GPIO.setmode(GPIO.BCM)
    GPIO.setwarnings(False)
    
    # Setup outputs from RPi to FPGA
    for pin in PINS_A + PINS_B + PINS_SEL:
        GPIO.setup(pin, GPIO.OUT)
        GPIO.output(pin, 0)
        
    # Setup inputs to RPi from FPGA
    for pin in PINS_Y:
        GPIO.setup(pin, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)

def write_bus(pins, value):
    """Writes a decimal number to pins (breaks it into bits)"""
    for i in range(len(pins)):
        bit = (value >> i) & 1
        GPIO.output(pins[i], bit)

def read_bus(pins):
    """Reads from pins and reconstructs a decimal number"""
    value = 0
    for i in range(len(pins)):
        bit = GPIO.input(pins[i])
        value |= (bit << i)
    return value

def expected_alu(a, b, sel):
    """Software model of your ALU to verify the hardware is correct"""
    if sel == 0: return (a & b) & 0xF
    if sel == 1: return (a | b) & 0xF
    if sel == 2: return (a + b) & 0xF
    if sel == 3: return (a - b) & 0xF
    if sel == 5: return (~(a & b)) & 0xF
    if sel == 6: return (a ^ b) & 0xF
    if sel == 7: return (a << 1) & 0xF
    return 0

def run_tests():
    setup()
    print("🚀 Starting 4-bit ALU Hardware Validation...")
    print("-" * 50)
    
    try:
        # Test all connected operations in SEL (0 to 7, except 4 which has no operation)
        for sel in [0, 1, 2, 3, 5, 6, 7]:
            op_names = {0:"AND", 1:"OR", 2:"ADD", 3:"SUB", 5:"NAND", 6:"XOR", 7:"SHL"}
            print(f"\nTesting Operation: {op_names[sel]} (SEL={sel})")
            
            # 5 random tests for each operation
            for _ in range(5):
                a = random.randint(0, 15) # 4 bit random
                b = random.randint(0, 15)
                
                # Write to hardware
                write_bus(PINS_A, a)
                write_bus(PINS_B, b)
                write_bus(PINS_SEL, sel)
                
                # Wait a bit (gives Python/GPIO time to stabilize)
                time.sleep(0.01)
                
                # Read from hardware
                hardware_y = read_bus(PINS_Y)
                software_y = expected_alu(a, b, sel)
                
                status = "✅ PASS" if hardware_y == software_y else "❌ FAIL"
                print(f" A={a:<2} | B={b:<2}  =>  Expected={software_y:<2} | Got={hardware_y:<2}  {status}")

    except KeyboardInterrupt:
        print("\nTest stopped by user.")
    finally:
        GPIO.cleanup()
        print("-" * 50)
        print("Done & Pins Cleaned.")

if __name__ == '__main__':
    run_tests()