# 10k-Hour-Timer-RP2040

An Eval Board for an RP2040 mcu + seven segment LED display + TM1638 driver + peripherals. 

## Project Structure

- `kicad/` - KiCad schematic and PCB design files
- `firmware/` - Firmware source code
- `datasheets/` - Component datasheets and documentation

## Hardware

This project uses the RP2040 microcontroller with supporting circuitry for power management, display drivers, and user interface components.
Note the firmware can be tested using a Raspberry Pi Pico board (original/v1 not Pico 2). 


## Getting Started

TODO - will post build log in the future.

## License

MIT License with other license files attached as used. 


## Hardware Revisions

### 2026-03-22 v1
Tagged commit: <link here>

Thanks to PCBWay for providing a partial discount which I put towards two pre-assemblied. Note that resistors R20 and R22 were populated with 220Ohms instead of 200Ohms as specified in the BOM. However these are just MOFSET gate protection resistors. 