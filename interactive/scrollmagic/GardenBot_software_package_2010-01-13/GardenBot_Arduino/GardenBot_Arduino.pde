/* ==================================================== 
 
GardenBot - brain module

beta version 0.1 (2010-08)
written by Andrew Frueh
http://gardenbot.org/

This is the code for the brain module of GardenBot.
This code is intended to be run on an Arduino board.
It provides most of the low-level functionallity for GardenBot.
It can communicate with the computer module for data logging and visualization.

==================================================== */


/*
abreviations

SM = SoilMoisture
TP = TemPerature
WS = WaterSolenoid
*/


// ----------------------------------------------------


// -------------------------
// >> pin definitions
// -------------------------
// this is where you define what pins you'll be using to hook up the various modules

// analog pins
const int SM1sensorPin = 0; // soil moisture 1
const int TP1sensorPin = 1; // soil temperature 1
const int LI1sensorPin = 2; // light level 1
const int SM2sensorPin = 3; // soil moisture 2

// digital pins
const int waterIsOnPin = 6; // if the water is on
const int WS1powerPin = 7; // power to the AC module that turns the water on
const int SM1powerPin = 9; // used to power the sensor intermitantly

// -------------------------
// << pin definitions
// -------------------------


// ----------------------------------------------------


// -------------------------
// >> soil moisture (SM)
// -------------------------
// this is all the stuff that relates to the soil moisture sensors

// here you set the frequency of the sensor reading in minutes -- slower frequency makes the sensor last longer
const unsigned long SMfrequency = 10; 

// these are the timings for the different states that the moisture sensor goes through during a sensor reading
const unsigned long SMsensorTimer_init = 2000; // 0 - only runs one time, the first time
const unsigned long SMsensorTimer_shakeDown = 1000; // 1 - square wave that 
const unsigned long SMsensorTimer_powerOn = 1000; // 2
const unsigned long SMsensorTimer_read = 10; // 3
const unsigned long SMsensorTimer_powerOff = 500; // 4
const unsigned long SMsensorTimer_sleep = SMfrequency*60000; // number of min. to sleep; 60,000 ms in one minute
const unsigned long SMsensorTimer_sleep_startup = 5000; // short sleep first several times to calibrate

// other variables and stuff
unsigned long SMsensorTimerRateCurrent = 0;
int SMsensorCycles = 0; // number of times the full cycle has completed
int SMprocessStep = 0;
int SM1sensorValue, SM2sensorValue, SM1sensorValueRaw, SM2sensorValueRaw, SM1moistureLevel, SM2moistureLevel;
//float SM1multiplier = 0.3; // used to warp the moisture level

// -------------------------
// << soil moisture (SM)
// -------------------------


// ----------------------------------------------------


// -------------------------
// >> other things
// -------------------------

// >> timers, etc.
const int timerDSPRate = 100; // display update timer
// current time and ALL "last" timers
unsigned long timerCurrentTime, timerSMLast, timerFastSensorLast, timerDSPLast, timerMSGlast;
// << timers, etc.

// >> messenging
const int MSGtimerRate = 1000; // clock speed of the messaging system
//int MSGactive = -1;
//char messageBuffer[128];
// << messenging

const int timerFastSensorRate = 1000; // 

// >> temperature (TP)
const int TPsmoothDepth = 10;
int TP1sensorRaw, TP1sensorCurr, TP1sensorHist[TPsmoothDepth], TP1currTempC, TP1currTempF;
int TP1offset = 40; // to zero out the moisture level when temp is added to it
// << temperature (TP)

// >> LightLevel (LI)
const int LIsmoothDepth = 10;
int LI1sensorRaw, LI1sensorCurr, LI1sensorHist[LIsmoothDepth];
// << LightLevel (LI)

// >> water is on
int waterIsOn = 0;
// << water

// -------------------------
// << other things
// -------------------------


// ----------------------------------------------------




// ---------------------------
// >> Arduino standard setup()
// ---------------------------

void setup(){

	delay(1000); //allow lcd to wake up.
	
	// >> initialize the pins
	
	// analog pins
	//pinMode(DSPtxPin,OUTPUT);
	pinMode(SM1sensorPin,INPUT);
	pinMode(SM2sensorPin,INPUT);
	pinMode(TP1sensorPin,INPUT);
	pinMode(LI1sensorPin,INPUT);
	
	// digital pins
	pinMode(SM1powerPin,OUTPUT);
	pinMode(WS1powerPin,OUTPUT);
	pinMode(waterIsOnPin,INPUT);
	
	// << initialize the pins
	
	// setup serial communication
	Serial.begin(9600);
  
}

// ---------------------------
// << Arduino standard setup()
// ---------------------------





// --------------------------
// >> Arduino standard loop()
// --------------------------

void loop(){

	// for all timers
	timerCurrentTime = millis();

	// -------------------------
	// >> fast timer for sensors
	// -------------------------

	if ( abs(timerCurrentTime - timerFastSensorLast) >= timerFastSensorRate) {
	timerFastSensorLast = timerCurrentTime;
	//
	
		// >> temperature
		TP1sensorRaw = analogRead(TP1sensorPin);
		TP1sensorCurr = TP1sensorRaw;
		//   >> smoothing math
		for(int i=TPsmoothDepth-1; i>0; i--){
		TP1sensorHist[i] = TP1sensorHist[i-1]; // move the data
		TP1sensorCurr += TP1sensorHist[i];
		}
		TP1sensorHist[0] = TP1sensorRaw;
		TP1sensorCurr = TP1sensorCurr/TPsmoothDepth;
		//   << smoothing math
		TP1currTempC = LM335ATempConvert(TP1sensorCurr,'C');
		TP1currTempF = LM335ATempConvert(TP1sensorCurr,'F');
		// << temperature
		
		
		// >> light level
		LI1sensorRaw = 1023 - analogRead(LI1sensorPin); // invert reading
		LI1sensorCurr = LI1sensorRaw;
		//   >> smoothing math
		for(int i=TPsmoothDepth-1; i>0; i--){
		LI1sensorHist[i] = LI1sensorHist[i-1]; // move the data
		LI1sensorCurr += LI1sensorHist[i];
		}
		LI1sensorHist[0] = LI1sensorRaw;
		LI1sensorCurr = LI1sensorCurr/TPsmoothDepth;
		//   << smoothing math
		// << light level
		
		
		// >> is water on?
		//waterIsOn = digitalRead(waterIsOnPin);
		
		if(digitalRead(waterIsOnPin)==HIGH){
		waterIsOn = 1;
		}else{
		waterIsOn = 0;
		}
		// << is water on?
	}

	// -------------------------
	// << fast timer for sensors
	// -------------------------

	
	
	
	
	// -------------------------------------------
	// >> slow timer for sensors (stepped processing timer)
	// -------------------------------------------
	
	
	if ( abs(timerCurrentTime - timerSMLast) >= SMsensorTimerRateCurrent) {
	timerSMLast = timerCurrentTime;
	//
		// sensor process stepping
		switch(SMprocessStep){
		case 0: // init
		  SMprocessStep = 1; 
		  SMsensorTimerRateCurrent = SMsensorTimer_init;
		  break;
		case 1: // powerOn 
		  SMprocessStep++; 
		  SMsensorTimerRateCurrent = SMsensorTimer_powerOn;
		  digitalWrite(SM1powerPin,HIGH);
		  break;
		case 2: // read 
		  SMprocessStep++; 
		  SMsensorTimerRateCurrent = SMsensorTimer_read;
		  sensorUpdate(1); 
		  break;
		case 3: // powerOff 
		  SMprocessStep++; 
		  SMsensorTimerRateCurrent = SMsensorTimer_powerOff;
		  digitalWrite(SM1powerPin,LOW);
		  break;
		case 4: // powerOn 
		  SMprocessStep++; 
		  SMsensorTimerRateCurrent = SMsensorTimer_powerOn;
		  //
		  break;
		case 5: // read 
		  SMprocessStep++; 
		  SMsensorTimerRateCurrent = SMsensorTimer_read;
		  sensorUpdate(2); 
		  break;
		case 6: // powerOff 
		  SMprocessStep++; 
		  SMsensorTimerRateCurrent = SMsensorTimer_powerOff;
		  //
		  break;
		case 7: // sleep
		  SMsensorTimerRateCurrent = SMsensorTimer_sleep;
		  SMsensorCycles++;
		  SMprocessStep = 1; // reset
		  break;
		}
	}

	// -------------------------------------------
	// << slow timer for sensors (stepped process)
	// -------------------------------------------
	
	
 
	// -------------------------------------------
	// >> message system timer
	// -------------------------------------------

	if ( abs(timerCurrentTime - timerMSGlast) >= MSGtimerRate) {
		timerMSGlast = timerCurrentTime;
		//
		messageIn();
	}

 	// -------------------------------------------
	// << message system timer
	// -------------------------------------------
    
}

// --------------------------
// << Arduino standard loop()
// --------------------------




// ---------------------------
// >> message system functions
// ---------------------------

// the Arduino serial buffer can hold 128 bytes. Each time you call read(), you empty that byte from the buffer.

void messageIn(){
  int lenTemp = Serial.available();
  
  if (lenTemp > 0) {
    byte incomingByte;
    for(int i=0; i<lenTemp; i++){
      // read the incoming byte:
      incomingByte = Serial.read();
      switch(incomingByte){
      case 'R': // R - report levels
        reportLevels();
        break;
      }
    }
  }
}

// this function called on message complete
void reportLevels(){
  Serial.print(SM1moistureLevel);
  Serial.print(",");
  Serial.print(TP1currTempC);
  Serial.print(",");
  Serial.print(LI1sensorCurr);
  Serial.print(",");
  Serial.print(waterIsOn);
  Serial.print(",");
  Serial.print(SM2moistureLevel);
  Serial.println("");
}

// ---------------------------
// << message system functions
// ---------------------------



// ---------------------------
// >> sensor functions
// ---------------------------

void sensorUpdate(int sensorNum){
 
  // ### Yikes! This is the same functionallity for each case, need to compact it
  switch(sensorNum){
  case 1:
  
    SM1sensorValueRaw = 1023 - analogRead(SM1sensorPin); // invert reading
    SM1sensorValue = SM1sensorValueRaw;
    SM1moistureLevel = constrain(SM1sensorValue,0,1023);
    break;
    
  case 2:
  
    SM2sensorValueRaw = analogRead(SM2sensorPin); // 
    SM2sensorValue = SM2sensorValueRaw;
    SM2moistureLevel = constrain(SM2sensorValue,0,1023);
    break;
    
  }
  
}

// ---------------------------
// << sensor functions
// ---------------------------




// ---------------------------
// >> temperature functions
// ---------------------------

// math learned from GreenRobotics in a comment on SparkFun's website
int LM335ATempConvert(int tempIn, char unitSystem){
  int KelvinC=273;
  int KelvinTemp = (long(tempIn) * 5 * 100) / 1023; // convert 
  int CelsiusTemp = KelvinTemp-KelvinC;
  int FahrenheitTemp = (CelsiusTemp)*(9/5)+32;
  int tempOut;

  switch(unitSystem){
  case 'K':
    tempOut = KelvinTemp;
    break;
  case 'C':
    tempOut = CelsiusTemp;
    break;
  case 'F':
    tempOut = FahrenheitTemp;
    break;
  }
  return tempOut;
}

// ---------------------------
// << temperature functions
// ---------------------------




