/* ==================================================== 
 
GardenBot - computer module, local-connection sub-module

beta version 2 (2011-01)
written by Andrew Frueh
http://gardenbot.org/

This is the code for the local-connection sub-module of the computer module of GardenBot.
This code should be run in the Processing environment (www.processing.org).
This code communicates with the brain module (Arduino) and can record the data to a text file and/or the web.
 
==================================================== */



// ============================================================
// Here can setup the basic things you will need to change to be specific to your GardenBot setup

String dataFileName = "sensorData.csv";

// This is the header for the data file
String[] fileDataTemplate = {
  "y-m-d_hr:mn,moisture level (50-100mm),temperature 1,light level 1,waterIsOn)",
  "MIN VALUES,0,0,0,0",
  "MAX VALUES,1023,100,1023,1" // no comma on last item
};

// List any URL that you want this script to report to
String[] listOfURLs = {
  "http://127.0.0.1/gardenbot/caseStudy/charts/convertSensorData.php",
  "http://gardenbot.org/caseStudy/charts/convertSensorData.php",
  "http://127.0.0.1/GardenBotCharts/convertSensorData.php" // no comma on last item
};




// ============================================================
// Initialize the variables

// to enable serial comunication
import processing.serial.*;


int stageMax = 600;
int stageWidth = stageMax;
int stageHeight = stageMax/2;
int numOfSensors = 4;
int[] sensorValues = new int[numOfSensors];
Serial myPort;

int sensorHistMarker = 0;
String[] sensorHistory = new String[1];
String[] sensorHistoryTrimmed = new String[1];
String[] URLexternalList = new String[1];


// messenging
 long messageTimerFreq = 60000;//60,000 = 1 min
 long logicTimerFreq = 900000;//900,000 = 15 min
 long currentTime, messageTimerLast, logicTimerLast;

//
PFont fontA;



// ============================================================
// this is a standard Processing function, it happens once on start up

void setup() {
  size(stageWidth, stageHeight);
  background(#ffffff);
  
  
  // List all the available serial ports
  println(Serial.list());
  
  // load the data
  sensorHistory = loadStrings(dataFileName);

  // get the URL(s) provided in an external file
  //listOfURLs = loadStrings("listOfURLs.txt");
  
  // if the file does not exist, then create it and initialize it with the header
  if(sensorHistory==null || sensorHistory.length==0){
    //sensorHistory[0] = append(sensorHistory, null);
    //
    saveStrings(dataFileName, fileDataTemplate); 
    // reload
    sensorHistory = loadStrings(dataFileName);
  }
    
  
  // write the data out to the files
  sendDataOut();
  
  println("sensorHistory[]: ");
  println(sensorHistory);
  println("STARTUP::  "+year()+"-"+month()+"-"+day()+"_"+hour()+":"+minute()+":"+second());
  // 
  
  
  myPort = new Serial(this, Serial.list()[2], 9600);
  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');
  
  // load the font for drawing
  fontA = loadFont("CourierNewPS-BoldMT-48.vlw");
  textAlign(CENTER);
  // Set the font and its size (in units of pixels)
  textFont(fontA, 16);
  /*
  */
  
}




// ============================================================
// this is a standard Processing function - it happens over and over again
//   note: draw() is equivalent to loop() on Arduino
// 

void draw() {

  // for all timers
  currentTime = millis();

  if ( abs(currentTime - messageTimerLast) >= messageTimerFreq) {
    messageTimerLast = currentTime;
    //
    // 82 = 'R'; for Report levels
    myPort.write(82);
    
  }
  
  
  if ( abs(currentTime - logicTimerLast) >= logicTimerFreq) {
    logicTimerLast = currentTime;
    //
    
    /*
    // load data if not already
    if(sensorFileData==null){
      sensorFileData = loadStrings(dataFileName);
    }
    */
    
    /*
    //int y = year(), m = month(), d = day(), hr = hour(), mn = minute(), sc = second();
    String timeStamp = year()+"-"+month()+"-"+day()+"_"+hour()+":"+minute();
    int moistureLevel1 = sensorValues[0];
    int temperature1 = sensorValues[1];
    int lightLevel1 = sensorValues[2];
    int waterIsOn = sensorValues[3];
    int moistureLevel2 = sensorValues[4];
    String stringTemp = timeStamp+","+moistureLevel1+","+temperature1+","+lightLevel1+","+waterIsOn+","+moistureLevel2;
    */
    
    String stringTemp = "";
    stringTemp += year()+"-"+month()+"-"+day()+"_"+hour()+":"+minute();
    stringTemp += ",";
    stringTemp += sensorValues[0]; // MS1
    stringTemp += ",";
    stringTemp += sensorValues[1]; // TP1
    stringTemp += ",";
    stringTemp += sensorValues[2]; // LI1
    stringTemp += ",";
    stringTemp += sensorValues[3]; // WIO
    
    println(stringTemp);
    
    //sensorHistory[sensorHistMarker] = stringTemp;
    if(sensorHistory[0]==null){
      sensorHistory[0] = stringTemp;
    }else{
      sensorHistory = append(sensorHistory, stringTemp);
    }
    sensorHistMarker++;

    // send data
    sendDataOut();

  }
  
  
  // >> draw the display
  //
  
  // draw the text
  int titlePosY = 20;
  int barTitlePosY = 50;
  
  fill(#222222);
  text("GardenBot - local communication sub-module", stageWidth/2, titlePosY);

  //int numOfBars = 3;
  int padding = round(stageWidth*.1);
  //float barWidth = (stageWidth/numOfBars)-(padding*(1+1/float(numOfBars)));
  int barWidth = int(stageWidth * .20);
  int barHeight = stageHeight-(padding*2);
  int i;
  float xTemp;
  float hTemp;
  // draw the bars
  
  // rect(x, y, width, height)
  // moisture sensor
  i = 0;
  xTemp = padding+(barWidth*i)+(padding*i);
  hTemp = barHeight*map(sensorValues[i],0,1023,0,1);
  fill(#aaaaaa);
  rect(xTemp, padding+(barHeight-hTemp), barWidth, padding+barHeight);
  fill(#555555);
  rect(xTemp, padding, barWidth, barHeight-hTemp);
  //
  fill(#222222);
  text("moisture", xTemp+(barWidth/2), barTitlePosY);
  
  // temp sensor
  i = 1;
  xTemp = padding+(barWidth*i)+(padding*i);
  hTemp = barHeight*map(sensorValues[i],0,1023,0,1);
  fill(#aaaaaa);
  rect(xTemp, padding+(barHeight-hTemp), barWidth, padding+barHeight);
  fill(#555555);
  rect(xTemp, padding, barWidth, barHeight-hTemp);
  //
  fill(#222222);
  text("temp", xTemp+(barWidth/2), barTitlePosY);
  
  // light sensor
  i = 2;
  xTemp = padding+(barWidth*i)+(padding*i);
  hTemp = barHeight*map(sensorValues[i],0,1023,0,1);
  fill(#aaaaaa);
  rect(xTemp, padding+(barHeight-hTemp), barWidth, padding+barHeight);
  fill(#555555);
  rect(xTemp, padding, barWidth, barHeight-hTemp);
  //
  fill(#222222);
  text("light", xTemp+(barWidth/2), barTitlePosY);
  
  
  /*
  int i;
  for(i=0;i<numOfBars;i=i+1) {   
    float xTemp = padding+(barWidth*i)+(padding*i);
    float hTemp = barHeight*map(sensorValues[i],0,1023,0,1);
    fill(#aaaaff);
    rect(xTemp, padding+(barHeight-hTemp), barWidth, padding+barHeight);
    fill(#aa5500);
    rect(xTemp, padding, barWidth, barHeight-hTemp);
  }
  */
   // << draw the display
  
}




// ============================================================
// this function sends the data out to a file and to the web

void sendDataOut(){
  
    // >> trim data
    String[] sensorHistoryHEAD = subset(sensorHistory, 0, 3);
    String[] sensorHistoryDATA = subset(sensorHistory, 3);
    // figure out the index of where to start reading the data
    int position = sensorHistoryDATA.length - 288; // 3 days worth = 288
    // aquire only the last x days worth of data
    sensorHistoryDATA = subset(sensorHistoryDATA, position);
    // splice the arrays back together
    sensorHistoryTrimmed = splice(sensorHistoryHEAD, sensorHistoryDATA, 3);
    // << trim data
    
    

    // write data to the file, full data
    saveStrings(dataFileName, sensorHistory);
    
    if(listOfURLs.length > 0){
      // create a string for sending as POST var
      String srtTemp = join(sensorHistoryTrimmed,"\n");
      //
      for(int i=0; i<listOfURLs.length; i++){
        // save data to the web 
        postNewItem(listOfURLs[i],"sensorData="+srtTemp);
      } 
    }
}




// ============================================================
// this function catches a serial event when the Arduino board responds

void serialEvent(Serial p) { 
  // get the ASCII string:
 // String inString = myPort.readStringUntil('\n');  
  String inString = p.readStringUntil('\n');

  if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);
    int[] rawValues = int(split(inString, ","));
    for(int i=0; i<numOfSensors; i++){
      sensorValues[i] = rawValues[i];
      //sensorValues[i] = map(rawValues[i], 0, 100, 0, 1);
    }
  }
}




// ============================================================
// 
// >> postNewItem()
//
// this function thanks to: Euskadi - from the Processing forum (pulled 2010-06-15)
// http://processing.org/discourse/yabb/YaBB.cgi?board=Integrate;action=display;num=1090838754

void postNewItem (String urlIN, String message) {  
  try {  
 
    URL      url;  
    URLConnection urlConn;  
    DataOutputStream   dos;  
    DataInputStream    dis;  
 
    url = new URL(urlIN);  
    urlConn = url.openConnection();  
    urlConn.setDoInput(true);  
    urlConn.setDoOutput(true);  
    urlConn.setUseCaches(false);  
    urlConn.setRequestProperty ("Content-Type", "application/x-www-form-urlencoded");  
 
    dos = new DataOutputStream (urlConn.getOutputStream());  
     
    dos.writeBytes(message);  
    dos.flush();  
    dos.close();  
 
    // the server responds by saying  
    // "SUCCESS" or "FAILURE"  
    dis = new DataInputStream(urlConn.getInputStream());  
    String s = dis.readLine();  
    dis.close();  
   
     /*
    if (s.equals("SUCCESS")) {  
 //toDoList.addItem(addTextField.getText());  
 ;//addTextField.setText("");  
    } else {  
 ; //addTextField.setText("Post Error!");  
    }  
    */
 
  } // end of "try"  
 
  catch (MalformedURLException mue) {  
    ; //addTextField.setText("mue error");  
  }  
  catch (IOException ioe) {  
    ; //addTextField.setText("IO Exception");  
  }  
 
}  
// << postNewItem()

