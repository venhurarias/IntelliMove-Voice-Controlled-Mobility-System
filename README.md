# IntelliMove Voice-Controlled Mobility System

IntelliMove is an embedded mobility control project that uses a microcontroller-based controller together with a Flutter mobile application for voice-command operation.

The system is designed to allow users to control movement through spoken commands from the mobile app, making it suitable for smart mobility prototypes, assistive devices, robotics projects, and wireless motion-control applications.

---

## 🚀 Features

- Voice command control through Flutter mobile app
- Wireless communication between mobile app and controller
- Directional movement control
- Start and stop control
- Embedded motor control logic
- Real-time command execution
- Expandable design for assistive mobility or robotics
- Simple and lightweight firmware structure

---

## 📱 Flutter Mobile App

The Flutter mobile app serves as the user control interface.

### Mobile App Capabilities

- Accepts voice commands from the user
- Converts spoken commands into control actions
- Sends commands to the controller
- Provides an easy-to-use mobile interface
- Can be expanded with buttons, status indicators, and device monitoring

### Example Voice Commands

- Forward
- Backward
- Left
- Right
- Stop
- Open
- Close

The actual command list may be customized depending on the firmware and mobile app implementation.

---

## 🔧 Controller / Firmware

The embedded controller receives commands from the Flutter mobile app and converts them into physical movement or actuator actions.

### Core Controller Functions

- Receive command input
- Interpret movement commands
- Control motor driver pins
- Stop motor movement when needed
- Execute actions based on mobile voice commands

---

## 🧰 Hardware Requirements

- ESP32 / Arduino-compatible controller
- Motor driver module
- DC motors / mobility motors
- Power supply or battery pack
- Bluetooth or WiFi communication module
- Chassis / mechanical frame
- Jumper wires and connectors

> ESP32 is recommended if WiFi or Bluetooth connectivity is required.

---

## 🔌 Typical Pin Configuration

Update this section based on the actual wiring used in the project.

| Component | Description |
|----------|-------------|
| Motor A  | Controls left/right or forward/backward movement |
| Motor B  | Controls opposite motor direction |
| Enable Pins | Controls motor speed if PWM is used |
| Communication Module | Receives commands from Flutter app |
| Power Supply | Powers motors and controller |

---

## ⚙️ System Workflow

1. User opens the Flutter mobile app
2. User speaks a command
3. App recognizes the voice command
4. App sends the command to the controller
5. Controller receives and processes the command
6. Motors or actuators respond based on the command
7. System waits for the next command

---

## 📡 Communication Flow

Flutter Mobile App
↓
Voice Recognition
↓
Command Processing
↓
Bluetooth / WiFi Communication
↓
ESP32 / Controller
↓
Motor Driver
↓
Motors / Actuators

---

## 🧠 Command Logic

| Command | Action |
|--------|--------|
| Forward | Move forward |
| Backward | Move backward |
| Left | Turn left |
| Right | Turn right |
| Stop | Stop all motors |
| Open | Activate open action if supported |
| Close | Activate close action if supported |

---

## 📦 Libraries

The firmware may use libraries depending on the board and communication method.

Common libraries may include:

- BluetoothSerial.h
- WiFi.h
- SoftwareSerial.h
- Arduino.h

Flutter mobile app may use:

- speech_to_text
- permission_handler
- flutter_bluetooth_serial or BLE package
- http or websocket package if WiFi/API based

---

## 🛠 Setup Instructions

### Controller Setup

1. Connect the motor driver to the controller
2. Connect motors to the motor driver
3. Connect the communication module if needed
4. Upload the firmware
5. Power the controller and motors

### Flutter Mobile Setup

1. Open the Flutter mobile project
2. Install dependencies using:

```bash
flutter pub get
```

3. Grant microphone permission
4. Connect to the controller through Bluetooth or WiFi
5. Speak a command to control the device

---

## 🔐 Safety Notes

- Test the motors while the device is lifted or secured
- Use a proper motor driver instead of connecting motors directly to the controller
- Use a separate power supply for motors when needed
- Add an emergency stop command
- Validate voice commands before executing movement
- Avoid operating near stairs, roads, water, or unsafe areas

---

## 📌 Notes

- Voice commands should be tested in a quiet environment
- Commands can be customized based on the mobile app
- The system can be expanded with obstacle detection, GPS, battery monitoring, and remote dashboard support
- ESP32 is recommended for wireless control and IoT expansion

---

## 📄 License

Open-source. Free to use, modify, and improve.

---

## 👨‍💻 Author

IntelliMove Voice-Controlled Mobility System


---

## 🔎 Firmware Libraries Detected

The uploaded firmware includes the following libraries:

- Adafruit_GFX.h
- Adafruit_MPU6050.h
- Adafruit_SH110X.h
- Adafruit_Sensor.h
- Chrono.h
- Streaming.h
- Wire.h


---

## 🔎 Detected Pin / Constant Definitions

- MOTOR_LEFT_A_PIN: 6
- MOTOR_LEFT_B_PIN: 7
- MOTOR_RIGHT_A_PIN: 2
- MOTOR_RIGHT_B_PIN: 3
- ECHO_R_PIN: 49
- TRIG_R_PIN: 48
- ECHO_F_PIN: 47
- TRIG_F_PIN: 46
- ECHO_L_PIN: 31
- TRIG_L_PIN: 30
- ECHO_B_PIN: 8
- TRIG_B_PIN: 9
- AUTOMATIC_BUTTON_PIN: A6
- SPEED_BUTTON_PIN: A5
- Y_PIN: A1
- X_PIN: A0
- BUZZER_PIN: 13
- OLED_RESET: -1
