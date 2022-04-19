import java.util.Arrays;
import java.util.Collections;
import java.util.Random;
import java.awt.Robot;
import java.awt.AWTException;
import java.awt.Rectangle;
import java.util.ArrayList;
import processing.core.PApplet;
import processing.sound.*;
import java.awt.*;
import javax.swing.*;
//import processing.javafx.*;// please install javafx
import java.lang.*;
//import javafx.util.*;

String[] phrases; //contains all of the phrases
int totalTrialNum = 3 + (int) random(3); //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 119; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;
PFont defaultFont;
PFont monospacedFont;

// Additional variables
String currSelection = "";
int lastSelectedFrame = -1; // used for initial-only cooldown
int cooldownFrameNum = 10;

void setup()
{
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing

  orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
  size(800, 800); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  defaultFont = createFont("Arial", 24);
  textFont(defaultFont); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes
  
  monospacedFont = createFont("Monospaced", 12);
  
}

void draw()
{
  background(255); //clear background
  drawWatch(); //draw watch background
  
  pushMatrix();
  fill(100);
  translate(width/2, height/2);
  rect(-sizeOfInputArea/2, -sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea);
  popMatrix();
  
  
  if (finishTime!=0) { // Finished
    fill(128);
    textAlign(CENTER);
    text("Finished", 280, 150);
    return;
  } else if (startTime==0) {   
    if (!mousePressed) { // Haven't started yet
      fill(128);
      textAlign(CENTER);
      text("Click to start time!", 280, 150); 
      lastSelectedFrame = frameCount;
    } else { // Start now
      nextTrial();
    }
  } else if (startTime != 0) { // Started
    // The target phrase & current typed phrase
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped +"|", 70, 140); //draw what the user has entered thus far

    //draw very basic next button
    fill(255, 0, 0);
    rect(600, 600, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", 650, 650); //draw next label
    
    processKeyboard();
  }
  
  
}

void mousePressed() {
  if (didMouseClick(600, 600, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}

void mouseReleased() {
  
  // THis avoids "click to start -> accidental click" issue
  if (frameCount - lastSelectedFrame < cooldownFrameNum) {
    return;
  }
  
  // Process click
  if (!currSelection.equals("")) {
    if (currSelection.equals("←")) {
      if (currentTyped.length() > 0) {
        currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
      }
    } else if (currSelection.equals("_")) {
      currentTyped += " ";
    } else {
      currentTyped += currSelection.toLowerCase();
    }
  }
}

void processKeyboard() {
  pushMatrix();
  
  float buttonSize = sizeOfInputArea / 10;
  float startX = -sizeOfInputArea / 2;
  float startY = 0;
  String currRow;
  boolean selected;
  currSelection = "";
  
  // Del Button
  selected = drawButton(width / 2 + startX + 8 * buttonSize, height / 2 + startY - buttonSize, 2 * buttonSize, buttonSize, color(#FFFFFF), color(#00FF00), " ←");
  if (currSelection.equals("") && selected) {
    currSelection = "←";
  }
  
  currRow = "QWERTYUIOP";
  for(int i = 0; i < currRow.length(); i++) {
    selected = drawButton(width / 2 + startX + i * buttonSize, height / 2 + startY, buttonSize, buttonSize, color(#FFFFFF), color(#00FF00), currRow.charAt(i) + "");
    if (currSelection.equals("") && selected) {
      currSelection = currRow.charAt(i) + "";
    }
  }
  
  currRow = "ASDFGHJKL";
  for(int i = 0; i < currRow.length(); i++) {
    selected = drawButton(width / 2 + startX + buttonSize / 2 + i * buttonSize, height / 2 + startY + buttonSize, buttonSize, buttonSize, color(#FFFFFF), color(#00FF00), currRow.charAt(i) + "");
    if (currSelection.equals("") && selected) {
      currSelection = currRow.charAt(i) + "";
    }
  }
  
  currRow = "ZXCVBNM";
  for(int i = 0; i < currRow.length(); i++) {
    selected = drawButton(width / 2 + startX + buttonSize + i * buttonSize, height / 2 + startY + 2 * buttonSize, buttonSize, buttonSize, color(#FFFFFF), color(#00FF00), currRow.charAt(i) + "");
    if (currSelection.equals("") && selected) {
      currSelection = currRow.charAt(i) + "";
    }
  }
  
  // Space
  selected = drawButton(width / 2 + startX + 3 * buttonSize / 2, height / 2 + startY + 3 * buttonSize, 6 * buttonSize, buttonSize, color(#FFFFFF), color(#00FF00), "");
  if (currSelection.equals("") && selected) {
    currSelection = "_";
  }
  
  // Draw current letter
  pushMatrix();
  translate(width/2, height/2);
  textAlign(CENTER);
  fill(200);
  text(currSelection.toLowerCase(), 0, -sizeOfInputArea/4); //draw current letter
  popMatrix();
  
  // reset
  
  
  popMatrix();
}

boolean drawButton(float x,   
                   float y, 
                   float w, 
                   float h, 
                   color defaultColor,
                   color selectedColor,
                   String text) {
  pushMatrix();
  boolean selected = didMouseClick(x, y, w, h);
  if (selected) fill(selectedColor);
  else fill(defaultColor);
  rect(x, y, w, h);
  
  fill(0);
  textFont(monospacedFont);
  text(text, x, y + h - 1);
  popMatrix();
  
  textFont(defaultFont);
  
  return selected;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////I'm not modifying anything below here//////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;

    System.out.println("Raw WPM: " + wpm); //output
    System.out.println("Freebie errors: " + freebieErrors); //output
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } else
    currTrialNum++; //increment trial number

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}


void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0;
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch, 0, 0);
  popMatrix();
}



//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}