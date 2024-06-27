import os
import serial
from PIL import Image

def repeat_bits(data):
    repeated_data = bytearray()
    for byte in data:
        for _ in range(4):
            repeated_data.append(byte)
    return repeated_data

def convert_to_8bit(image_path, output_data_file):
    try:
        # Open the image and convert to grayscale (8-bit)
        img = Image.open(image_path).convert('L')
        img_data = img.tobytes()

        # Repeat each byte 4 times
        repeated_data = repeat_bits(img_data)

        # Save the repeated data to a binary file
        with open(output_data_file, 'wb') as f:
            f.write(repeated_data)

        print(f"Converted {image_path} to 8-bit data format with repeated bits: {output_data_file}")
    except Exception as e:
        print(f"Error converting image: {e}")

def send_data_via_serial(data_file_path, serial_port):
    try:
        with serial.Serial(serial_port, 115200) as ser:
            with open(data_file_path, 'rb') as f:
                data = f.read()
                ser.write(data)
                print(f"Data sent via {serial_port}")
    except Exception as e:
        print(f"Error sending data: {e}")

def main():
    try:
        # Original JPEG image path
        original_image_path = input("Enter the path to the JPEG image: ")

        # Output path for 8-bit data format (arbitrary filename in the same directory)
        data_file_path = os.path.join(os.path.dirname(original_image_path), '8bit_data.bin')

        # Convert JPEG to 8-bit data format with repeated bits
        convert_to_8bit(original_image_path, data_file_path)

        # Send the data via COM4 port
        send_data_via_serial(data_file_path, 'COM6')

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
