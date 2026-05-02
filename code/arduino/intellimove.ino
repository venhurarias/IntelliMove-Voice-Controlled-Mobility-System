#include <Streaming.h>
#include <Chrono.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SH110X.h>


#define MOTOR_LEFT_A_PIN 6
#define MOTOR_LEFT_B_PIN 7
#define MOTOR_RIGHT_A_PIN 2
#define MOTOR_RIGHT_B_PIN 3

#define ACTUATOR_LEFT_A 42
#define ACTUATOR_LEFT_B 43
#define ACTUATOR_RIGHT_A 44
#define ACTUATOR_RIGHT_B 45

#define ECHO_R_PIN 49
#define TRIG_R_PIN 48

#define ECHO_F_PIN 47
#define TRIG_F_PIN 46

#define ECHO_L_PIN 31
#define TRIG_L_PIN 30
#define ECHO_B_PIN 8
#define TRIG_B_PIN 9

#define AUTOMATIC_BUTTON_PIN A6
#define SPEED_BUTTON_PIN A5
#define Y_PIN A1
#define X_PIN A0

#define YELLOW_LIGHT A2
#define RED_LIGHT A3
#define GREEN_LIGHT A4
#define BUZZER_PIN 13


#define SCREEN_WIDTH 64    // SH1107 width in pixels
#define SCREEN_HEIGHT 128  // SH1107 height in pixels
#define OLED_RESET -1
#define textSize 1

#define ROLL_SENSITIVITY 5
#define PITCH_SENSITIVITY 5
#define LOW_SPEED 120
#define HIGH_SPEED 180
#define AUTO_BACKWARD_SEC 2000
#define AUTO_STOP_SEC 2000
#define AUTO_TURN_SEC 5000
#define FORWARD_OBSTACLE_SENSITIVITY 3000

bool inJoystick = false;
bool forward_detect = false;
bool inForward = false;
bool inBackward = false;
int displayMode = 0;
int obstacleMode = 0;
int distanceBack;

Chrono myChrono, sensorChrono, buzzerChrono, readingChrono, obstacleChrono;

Adafruit_MPU6050 mpu;
Adafruit_SH1107 display = Adafruit_SH1107(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
unsigned long beepInterval = 1000;
int left, right;
bool isInGoRight;
bool isMoving = false;

void setup() {

  pinMode(Y_PIN, INPUT);
  pinMode(X_PIN, INPUT);

  pinMode(AUTOMATIC_BUTTON_PIN, INPUT_PULLUP);
  pinMode(SPEED_BUTTON_PIN, INPUT_PULLUP);

  pinMode(MOTOR_LEFT_A_PIN, OUTPUT);
  pinMode(MOTOR_LEFT_B_PIN, OUTPUT);
  pinMode(MOTOR_RIGHT_A_PIN, OUTPUT);
  pinMode(MOTOR_RIGHT_B_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);

  pinMode(ACTUATOR_LEFT_A, OUTPUT);
  pinMode(ACTUATOR_LEFT_B, OUTPUT);
  pinMode(ACTUATOR_RIGHT_A, OUTPUT);
  pinMode(ACTUATOR_RIGHT_B, OUTPUT);

  pinMode(RED_LIGHT, OUTPUT);
  pinMode(GREEN_LIGHT, OUTPUT);
  pinMode(YELLOW_LIGHT, OUTPUT);

  pinMode(ECHO_F_PIN, INPUT);
  pinMode(TRIG_F_PIN, OUTPUT);
  pinMode(ECHO_R_PIN, INPUT);
  pinMode(TRIG_R_PIN, OUTPUT);
  pinMode(ECHO_L_PIN, INPUT);
  pinMode(TRIG_L_PIN, OUTPUT);
  pinMode(ECHO_B_PIN, INPUT);
  pinMode(TRIG_B_PIN, OUTPUT);

  Serial.begin(9600);
  Serial.setTimeout(100);

  Serial3.begin(9600);
  Serial3.setTimeout(100);

  mpu.begin();
  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);

  display_setup();

  display_initialize();
  delay(1000);
  display_school();
  delay(1000);
  display_course();
  delay(1000);
  display_names();
  delay(1000);
  display_welcome();
  delay(1000);
  display_status("LOW", "AUTOMATIC");
}

void loop() {
  // Serial << "F: " << forwardReading() << endl;
  // delay(100);
  // Serial << "F: " << forwardReading() << "\t\tR: " << rightReading() << "\t\tL: " << leftReading() << "\t\tB: " << backReading() << endl;
  // delay(1000);
  // Serial << "Is Automatic: " << isOnAutomatic() << "\t\tIn High Speed: " << isOnHighSpeed() << endl;
  // Serial<<"X: "<<getXValue()< <"\t\tY: "<<getYValue()<<endl;
  // testing();
  // mpuTest();
  // getI2CAddress();
  // bluetoothTest();
  // manualProcess();
  // automaticActuator();
  // showOledDisplay();
  // turnWheelchair();
  normalProcess();
}

void showOledDisplay() {
  if (isOnAutomatic()) {
    if (isOnHighSpeed()) {
      if (displayMode != 4) {
        displayMode = 4;
        goStop();
        display_status("HIGH", "AUTOMATIC");
      }
    } else {
      if (displayMode != 0) {
        displayMode = 0;
        goStop();
        display_status("LOW", "AUTOMATIC");
      }
    }


  } else {
    if (isOnHighSpeed()) {
      if (displayMode != 1) {
        displayMode = 1;
        goStop();
        display_status("HIGH", "MANUAL");
      }
    } else {
      if (displayMode != 2) {
        displayMode = 2;
        goStop();
        display_status("LOW", "MANUAL");
      }
    }
  }
}

void bluetoothTest() {
  if (Serial3.available()) {
    String reading = Serial3.readString();
    reading.trim();
    Serial << reading << endl;
  }
}


void automaticActuator() {

  if (!isMoving) {
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);
    float tiltRoll = asin(constrain(a.acceleration.y / 9.81, -1.0, 1.0)) * 180.0 / PI;
    Serial << "Roll: " << tiltRoll << " deg" << endl;
    tiltRoll = tiltRoll + 2;

    float tiltPitch = asin(constrain(a.acceleration.z / 9.81, -1.0, 1.0)) * 180.0 / PI;
    // Serial << "Pitch: " << tiltPitch << " deg" << endl;
    tiltPitch = tiltPitch + 5;

    if (abs(tiltPitch) < PITCH_SENSITIVITY) {
      if (abs(tiltRoll) < ROLL_SENSITIVITY) {
        actuatorOff();
      } else if (tiltRoll > 0) {
        Serial << "LEFT" << endl;
        actuatorLeftUp();
        actuatorRightDown();

      } else {
        Serial << "RIGHT" << endl;
        actuatorLeftDown();
        actuatorRightUp();
      }
    } else if (tiltPitch > 0) {
      actuatorRightDown();
      actuatorLeftDown();
    } else {
      actuatorRightUp();
      actuatorLeftUp();
    }
  } else {
    actuatorOff();
  }
}


void mpuTest() {
  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);
  Serial.print("Acceleration X: ");
  Serial.print(a.acceleration.x);
  Serial.print(", Y: ");
  Serial.print(a.acceleration.y);
  Serial.print(", Z: ");
  Serial.print(a.acceleration.z);
  Serial.println(" m/s^2");

  Serial.print("Rotation X: ");
  Serial.print(g.gyro.x);
  Serial.print(", Y: ");
  Serial.print(g.gyro.y);
  Serial.print(", Z: ");
  Serial.print(g.gyro.z);
  Serial.println(" rad/s");

  Serial.print("Temperature: ");
  Serial.print(temp.temperature);
  Serial.println(" degC");

  Serial.println("");
  delay(500);
}

void getI2CAddress() {
  byte error, address;
  int nDevices;

  Serial.println("Scanning...");

  nDevices = 0;
  for (address = 1; address < 127; address++) {
    // The i2c_scanner uses the return value of
    // the Write.endTransmisstion to see if
    // a device did acknowledge to the address.
    Wire.beginTransmission(address);
    error = Wire.endTransmission();

    if (error == 0) {
      Serial.print("I2C device found at address 0x");
      if (address < 16)
        Serial.print("0");
      Serial.print(address, HEX);
      Serial.println("  !");

      nDevices++;
    } else if (error == 4) {
      Serial.print("Unknown error at address 0x");
      if (address < 16)
        Serial.print("0");
      Serial.println(address, HEX);
    }
  }
  if (nDevices == 0)
    Serial.println("No I2C devices found\n");
  else
    Serial.println("done\n");

  delay(5000);  // wait 5 seconds for next scan
}

void normalProcess() {
  automaticActuator();
  showOledDisplay();
  if (isOnAutomatic()) {
    automaticProcess();
  } else {
    manualProcess();
  }
}

void allLightOn() {
  YellowOn();
  GreenOn();
  RedOn();
}

void allLightOff() {
  YellowOff();
  GreenOff();
  RedOff();
}


bool turnWheelchair() {
   int speed = LOW_SPEED;
  if (isOnHighSpeed()) {
    speed = HIGH_SPEED;
  }
  if (Serial3.available()) {
    String reading = Serial3.readString();
    reading.trim();
    Serial << reading << endl;
    if (reading.indexOf("0") != -1) {
      Serial << "Stop" << endl;
      goStop();
      inForward = false;
      inBackward = false;
      inJoystick = false;
      return true;
    }
  }


  if (!isOnAutomatic()) {
    goStop();
    return true;
  }
  switch (obstacleMode) {
    case 0:
      goStop();
      if (obstacleChrono.hasPassed(1000)) {
        obstacleMode = 1;
        obstacleChrono.restart();
      }
      break;

    case 1:
      goBackward(speed);
      if (obstacleChrono.hasPassed(AUTO_BACKWARD_SEC)) {
        obstacleMode = 2;
        obstacleChrono.restart();
      }
      break;

    case 2:
      goStop();
      if (obstacleChrono.hasPassed(AUTO_STOP_SEC)) {
        obstacleMode = 3;
        obstacleChrono.restart();
      }
      break;

    case 3:
      left = leftReading();
      right = rightReading();
      if (left == 0) {
        isInGoRight = true;
      } else if (right == 0) {
        isInGoRight = false;
      } else if (abs(left) > abs(right)) {
        isInGoRight = false;
      } else {
        isInGoRight = true;
      }
      obstacleMode = 4;

      break;

    case 4:
      if (isInGoRight) {
        goLeft(speed);
      } else {
        goRight(speed);
      }

      if (obstacleChrono.hasPassed(AUTO_TURN_SEC)) {
        obstacleMode = 5;
        obstacleChrono.restart();
        goStop();
      }
      break;

    case 5:
      return true;
      break;
  }
  return false;
}

void automaticProcess() {
  int speed = LOW_SPEED;
  if (isOnHighSpeed()) {
    speed = HIGH_SPEED;
  }
  if (inJoystick) {
    if (myChrono.hasPassed(500)) {
      goStop();
      inForward = false;
      inBackward = false;
      inJoystick = false;
    }
  }
  if (inBackward) {
    if (readingChrono.hasPassed(1000)) {
      readingChrono.restart();
      distanceBack = backReading();
      if (distanceBack > 0 && distanceBack < 3000) {
        beepInterval = constrain(map(distanceBack, 1000, 3000, 100, 1500), 100, 1500);
      } else {
        beepInterval = 1500;  // no object or out of range
      }
    }
    Serial << distanceBack << endl;

    if (buzzerChrono.hasPassed(1000)) {
      buzzerChrono.restart();
      BuzzerOn();
      delay(50);
      BuzzerOff();
    }
  } else {
    BuzzerOff();
  }

  if (inForward) {
    if (sensorChrono.hasPassed(100)) {
      int forwardVal = abs(forwardReading());
      if (forwardVal < FORWARD_OBSTACLE_SENSITIVITY && forwardVal != 0) {
        forward_detect = true;
        allLightOn();

      } else {
        forward_detect = false;
        allLightOff();
      }
    }
    if (forward_detect) {
      goStop();
      obstacleMode = 0;
      while (!turnWheelchair())
        ;
      inForward = false;
      inBackward = false;
      inJoystick = false;

    } else {
      goForward(speed);
    }
  } else {
    allLightOff();
  }


  if (Serial3.available()) {
    String reading = Serial3.readString();
    reading.trim();

    Serial << reading << endl;
    if (reading.indexOf("0") != -1) {
      Serial << "Stop" << endl;
      goStop();
      inForward = false;
      inBackward = false;
      inJoystick = false;
    } else if (reading.indexOf("1") != -1) {
      Serial << "Forward" << endl;
      inForward = true;
      inBackward = false;
      inJoystick = false;
    } else if (reading.indexOf("2") != -1) {
      Serial << "Backward" << endl;
      goBackward(speed);
      inForward = false;
      inBackward = true;
      inJoystick = false;
    } else if (reading.indexOf("3") != -1) {
      Serial << "Right" << endl;
      goRight(speed);
      inForward = false;
      inBackward = false;
      inJoystick = false;
    } else if (reading.indexOf("4") != -1) {
      Serial << "Left" << endl;
      goLeft(speed);
      inForward = false;
      inBackward = false;
      inJoystick = false;
    } else if (reading.indexOf("w") != -1) {
      Serial << "Forward" << endl;
      // goForward(LOW_SPEED);
      inForward = true;
      inBackward = false;
      inJoystick = true;
      myChrono.restart();
    } else if (reading.indexOf("s") != -1) {
      Serial << "Backward" << endl;
      goBackward(speed);
      inForward = false;
      inBackward = true;
      inJoystick = true;
      myChrono.restart();
    } else if (reading.indexOf("a") != -1) {
      Serial << "Right" << endl;
      goRight(speed);
      inForward = false;
      inBackward = false;
      inJoystick = true;
      myChrono.restart();
    } else if (reading.indexOf("d") != -1) {
      Serial << "Left" << endl;
      goLeft(speed);
      inForward = false;
      inBackward = false;
      inJoystick = true;
      myChrono.restart();
    }
  }
}

void manualProcess() {
  if (Serial3.available()) {
    String reading = Serial3.readString();
  }
  int rawX = getXValue();
  int rawY = getYValue();

  int speed = LOW_SPEED;
  if (isOnHighSpeed()) {
    speed = HIGH_SPEED;
  }
  // Normalize to center around 0
  float x = (float)(rawX - 512);
  float y = (float)(rawY - 512);


  if (abs(x) < 50 && abs(y) < 50) {
    Serial << "STOP" << endl;
    goStop();
  } else if (y < -100 && abs(x) < 100) {
    Serial << "Forward" << endl;
    goForward(speed);
  } else if (y > 100 && abs(x) < 100) {
    Serial << "Backward" << endl;
    goBackward(speed);
  } else if (x < -100 && abs(y) < 100) {
    Serial << "Left" << endl;
    goLeft(speed);
  } else if (x > 100 && abs(y) < 100) {
    Serial << "Right" << endl;
    goRight(speed);
  }
}


int forwardReading() {
  digitalWrite(TRIG_F_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_F_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_F_PIN, LOW);
  return pulseIn(ECHO_F_PIN, HIGH);
}

int rightReading() {
  digitalWrite(TRIG_R_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_R_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_R_PIN, LOW);
  return pulseIn(ECHO_R_PIN, HIGH);
}

int leftReading() {
  digitalWrite(TRIG_L_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_L_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_L_PIN, LOW);
  return pulseIn(ECHO_L_PIN, HIGH);
}


int backReading() {
  digitalWrite(TRIG_B_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_B_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_B_PIN, LOW);
  return pulseIn(ECHO_B_PIN, HIGH);
}
int getXValue() {
  return analogRead(X_PIN);
}

int getYValue() {
  return analogRead(Y_PIN);
}

void testing() {
  if (Serial.available()) {
    String reading = Serial.readString();  //isasave yung nabasa sa "reading" variable
    reading.trim();
    Serial << reading << endl;
    if (reading == "0") {
      Serial << "All Off" << endl;
      allOff();
    } else if (reading == "w") {
      Serial << "Forward" << endl;
      goForward(HIGH_SPEED);
    } else if (reading == "s") {
      Serial << "Backward" << endl;
      goBackward(HIGH_SPEED);
    } else if (reading == "a") {
      Serial << "Left" << endl;
      goLeft(HIGH_SPEED);
    } else if (reading == "d") {
      Serial << "Right" << endl;
      goRight(HIGH_SPEED);
    } else if (reading == "z") {
      Serial << "Red On" << endl;
      RedOn();
    } else if (reading == "x") {
      Serial << "Green On" << endl;
      GreenOn();
    } else if (reading == "c") {
      Serial << "Yellow On" << endl;
      YellowOn();
    } else if (reading == "v") {
      Serial << "Buzzer On" << endl;
      BuzzerOn();
    } else if (reading == "i") {
      Serial << "Left Up" << endl;
      actuatorLeftUp();
    } else if (reading == "k") {
      Serial << "Left Down" << endl;
      actuatorLeftDown();
    } else if (reading == "o") {
      Serial << "Right Up" << endl;
      actuatorRightUp();
    } else if (reading == "l") {
      Serial << "Right Down" << endl;
      actuatorRightDown();
    }
  }
}

bool isOnAutomatic() {
  return !digitalRead(AUTOMATIC_BUTTON_PIN);
}

bool isOnHighSpeed() {
  return !digitalRead(SPEED_BUTTON_PIN);
}
void allOff() {
  goStop();
  RedOff();
  GreenOff();
  YellowOff();
  BuzzerOff();
  actuatorOff();
}

void BuzzerOn() {
  digitalWrite(BUZZER_PIN, HIGH);
}

void BuzzerOff() {
  digitalWrite(BUZZER_PIN, LOW);
}


void RedOn() {
  digitalWrite(RED_LIGHT, HIGH);
}

void RedOff() {
  digitalWrite(RED_LIGHT, LOW);
}

void GreenOn() {
  digitalWrite(GREEN_LIGHT, HIGH);
}

void GreenOff() {
  digitalWrite(GREEN_LIGHT, LOW);
}

void YellowOn() {
  digitalWrite(YELLOW_LIGHT, HIGH);
}

void YellowOff() {
  digitalWrite(YELLOW_LIGHT, LOW);
}

//120 max speed
void goBackward(int speed) {
  analogWrite(MOTOR_LEFT_A_PIN, speed);
  analogWrite(MOTOR_LEFT_B_PIN, 0);
  analogWrite(MOTOR_RIGHT_A_PIN, speed);
  analogWrite(MOTOR_RIGHT_B_PIN, 0);
  isMoving = true;
}

void goForward(int speed) {
  analogWrite(MOTOR_LEFT_A_PIN, 0);
  analogWrite(MOTOR_LEFT_B_PIN, speed);
  analogWrite(MOTOR_RIGHT_A_PIN, 0);
  analogWrite(MOTOR_RIGHT_B_PIN, speed);
  isMoving = true;
}

void goLeft(int speed) {
  analogWrite(MOTOR_LEFT_A_PIN, 0);
  analogWrite(MOTOR_LEFT_B_PIN, speed);
  analogWrite(MOTOR_RIGHT_A_PIN, speed);
  analogWrite(MOTOR_RIGHT_B_PIN, 0);
  isMoving = true;
}

void goRight(int speed) {
  analogWrite(MOTOR_LEFT_A_PIN, speed);
  analogWrite(MOTOR_LEFT_B_PIN, 0);
  analogWrite(MOTOR_RIGHT_A_PIN, 0);
  analogWrite(MOTOR_RIGHT_B_PIN, speed);
  isMoving = true;
}

void goStop() {
  analogWrite(MOTOR_LEFT_A_PIN, 0);
  analogWrite(MOTOR_LEFT_B_PIN, 0);
  analogWrite(MOTOR_RIGHT_A_PIN, 0);
  analogWrite(MOTOR_RIGHT_B_PIN, 0);
  isMoving = false;
}

void actuatorOff() {
  actuatorLeftOff();
  actuatorRightOff();
}

void actuatorLeftOff() {
  digitalWrite(ACTUATOR_LEFT_A, LOW);
  digitalWrite(ACTUATOR_LEFT_B, LOW);
}

void actuatorLeftUp() {
  digitalWrite(ACTUATOR_LEFT_A, HIGH);
  digitalWrite(ACTUATOR_LEFT_B, LOW);
}

void actuatorLeftDown() {
  digitalWrite(ACTUATOR_LEFT_A, LOW);
  digitalWrite(ACTUATOR_LEFT_B, HIGH);
}
void actuatorRightOff() {
  digitalWrite(ACTUATOR_RIGHT_A, LOW);
  digitalWrite(ACTUATOR_RIGHT_B, LOW);
}
void actuatorRightUp() {
  digitalWrite(ACTUATOR_RIGHT_A, HIGH);
  digitalWrite(ACTUATOR_RIGHT_B, LOW);
}

void actuatorRightDown() {
  digitalWrite(ACTUATOR_RIGHT_A, LOW);
  digitalWrite(ACTUATOR_RIGHT_B, HIGH);
}

void drawCenteredText(const char* lines[], uint8_t numLines) {
  display.setTextSize(textSize);       // normal 1:1 pixel scale
  display.setTextColor(SH110X_WHITE);  // white text

  display_clear();
  // 1) compute text metrics
  uint8_t ts = textSize;                          // usually 1
  uint8_t lineHeight = 7 + 1 * ts;                // font height * size
  uint16_t blockH = numLines * lineHeight;        // total height of all lines
  int16_t startY = (SCREEN_HEIGHT - blockH) / 2;  // top Y to center vertically

  // 2) loop and draw each line centered
  for (uint8_t i = 0; i < numLines; i++) {
    int16_t x1, y1;
    uint16_t w, h;
    display.getTextBounds(lines[i], 0, 0, &x1, &y1, &w, &h);
    int16_t x = (SCREEN_WIDTH - w) / 2;     // center X
    int16_t y = startY + (i * lineHeight);  // line’s Y position
    display.setCursor(x, y);
    display.print(lines[i]);
  }
}

void display_setup() {
  if (!display.begin(0x3C, true)) {
    Serial.println("SH1107 initialization failed!");
    while (1) delay(10);
  }
  display.clearDisplay();
}

void display_clear() {
  display.clearDisplay();
}

void display_initialize() {
  const char* lines[]{
    "System",
    "Start",
    "Please",
    "Wait!"
  };
  const uint8_t numLines = sizeof(lines) / sizeof(lines[0]);

  drawCenteredText(lines, numLines);

  display.display();
}

void display_school() {
  const char* lines[]{
    "Batangas",
    "State",
    "University",
    "The",
    "National",
    "Engg.",
    "University",
    "Alangilan",
    "Campus"
  };
  const uint8_t numLines = sizeof(lines) / sizeof(lines[0]);

  drawCenteredText(lines, numLines);

  display.display();
}

void display_course() {
  const char* lines[]{
    "Bachelor",
    "of",
    "Science in",
    "Computer",
    "Engg.",
  };
  const uint8_t numLines = sizeof(lines) / sizeof(lines[0]);

  drawCenteredText(lines, numLines);

  display.display();
}

void display_welcome() {
  const char* lines[]{
    "WELCOME!"
  };
  const uint8_t numLines = sizeof(lines) / sizeof(lines[0]);

  drawCenteredText(lines, numLines);

  display.display();
}

void display_names() {
  const char* lines[]{
    "Coronel",
    "Falceso",
    "Lalu",
    " ",
    "CPE-4201",
  };
  const uint8_t numLines = sizeof(lines) / sizeof(lines[0]);

  drawCenteredText(lines, numLines);

  display.display();
}


void display_status(const char* speed, const char* mode) {
  display_clear();

  const uint8_t lineHeight = 8 * textSize;  // approx 8px per line
  const uint8_t spacing = 4;                // spacing after line
  uint8_t cursorY = 32;                     // start higher for padding

  // Draw "Speed:" and speed
  display.setTextSize(textSize);
  display.setTextColor(SH110X_WHITE);
  display.setCursor((SCREEN_WIDTH - 6 * strlen("Speed:")) / 2, cursorY);
  display.print("Speed:");
  cursorY += lineHeight + spacing;

  display.setCursor((SCREEN_WIDTH - 6 * strlen(speed)) / 2, cursorY);
  display.print(speed);
  cursorY += lineHeight + spacing;
  cursorY += spacing * 2;
  // Draw horizontal line
  display.drawLine(0, cursorY, SCREEN_WIDTH, cursorY, SH110X_WHITE);
  cursorY += spacing * 4;  // Add space after the line

  // Draw "Mode:" and mode
  display.setCursor((SCREEN_WIDTH - 6 * strlen("Mode:")) / 2, cursorY);
  display.print("Mode:");
  cursorY += lineHeight + spacing;

  display.setCursor((SCREEN_WIDTH - 6 * strlen(mode)) / 2, cursorY);
  display.print(mode);

  display.display();
}