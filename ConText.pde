import processing.sound.*;

// -------------------------------------------------- //
// -------------------------------------------------- //
//                   Daniel James                     //
// -------------------------------------------------- //
// -------------------------------------------------- //

TriOsc triOsc;
Env env; 

// Used for visual and tonal generation
int a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z;

int mostFrequentCount = 0;
String mostFrequentLetter = "";

// Initialize variables
Table data;

int rowCount;

int backgroundR;
int backgroundG;
int backgroundB;

int frameR;
int frameG;
int frameB;

int xMod = 10;
int yMod = 10;

int currentMessage = 0;

// Arrays
String[] receivedOrSent;
String[] phoneNumber;
String[] contactName;
int[] hour;
String[] messageContent;

// -------------------------------------------------- //
//                        SETUP                       //
// -------------------------------------------------- //

void setup() {
  size(400, 700);
  smooth();
  noStroke();

  // Create triangle wave and envelope for note generation
  triOsc = new TriOsc(this);
  env  = new Env(this);

  // Load the texts
  data = loadTable("SMS2.csv", "header");

  // Get a row count
  rowCount = data.getRowCount();

  // The spreadsheet is set up in a long column with groups of 5
  // 1 - "Received" or "Sent"
  // 2 - Phone number
  // 3 - Contact name
  // 4 - Timestamp
  // 5 - Message content

  receivedOrSent  = new String[(rowCount / 5)];
  phoneNumber = new String[(rowCount / 5)];
  contactName = new String[(rowCount / 5)];
  hour = new int[(rowCount / 5)];
  messageContent = new String[(rowCount / 5)];

  // Iterate through the .csv file and add the data into arrays so that 
  // we can access them from draw() without having to iterate every time
  for (int i = 0; i < rowCount; i++) {
    if (i % 5 == 0) {

      // "Received" or "Sent"
      receivedOrSent[i / 5] = data.getRow(i).getString("message");

      // Phone number
      phoneNumber[i / 5] = data.getRow(i + 1).getString("message");

      // Contact name
      contactName[i / 5] = data.getRow(i + 2).getString("message");

      // Hour of day
      String[] timeStampSplit = splitTokens(data.getRow(i + 3).getString("message"), " ");
      String[] timeSplit = splitTokens(timeStampSplit[1], ":");
      hour[i / 5] = parseInt(timeSplit[0]);

      // Message content
      messageContent[i / 5] = data.getRow(i + 4).getString("message");
    }
  }
}

// -------------------------------------------------- //
//                        DRAW                        //
// -------------------------------------------------- //

void draw() {
  
  // Draw the frame
  colourFrame(contactName[currentMessage]);

  // Draw the background colour
  colourBackground(hour[currentMessage]);

  // Draw the boxes
  drawMessageBoxes(messageContent[currentMessage]);

  // Generate a note
  createTones(messageContent[currentMessage]);

  // Wait for the number of milliseconds that the current message is long in characters
  delay(messageContent[currentMessage].length());

  // Go to the next message
  currentMessage++;

  // Reset and wait 10 seconds when the last message is reached
  if (currentMessage == (rowCount / 5)) {
    currentMessage = 0;
    println("------------------RESTARTING------------------");
    println("------------------RESTARTING------------------");
    println("------------------RESTARTING------------------");
    println("------------------RESTARTING------------------");
    println("------------------RESTARTING------------------");
    println("------------------RESTARTING------------------");
    println("------------------RESTARTING------------------");
    println("------------------RESTARTING------------------");
    println("------------------RESTARTING------------------");
    delay(10000);
  }
}

// ------------------------------------------------------------------------------------//
//   This function picks a tint to use in the visual based on the contact's initials   //
// ------------------------------------------------------------------------------------//

void colourFrame(String contact) {

  // Split the contact's name into first and last name
  String[] names = splitTokens(contact);

  // If the contact only has one name, or no name, do this
  if (names.length <= 1) {
    frameR = (int)random(255);
    frameG = (int)random(255);
    frameB = (frameR + frameG) / 2;
  }

  // Normal case: do this
  else {
    int firstInitial = names[0].charAt(0);
    int lastInitial = names[1].charAt(0);

    // Assign the first initial (a - z) a number from 0 - 255
    if (firstInitial >= 65 && firstInitial <= 90 && lastInitial >= 65 && lastInitial <= 90) {
      // turn them into numbers from 0 to 25
      firstInitial -= 65;
      lastInitial -= 65;
      // map them to a value from 0 to 255
      firstInitial *= (255.0 / 25.0);
      lastInitial *= (255.0 / 25.0);
    }

    // Assign the first initial (A - Z) a number from 0 - 255
    else if (firstInitial >= 97 && firstInitial <= 122 && lastInitial >= 97 && lastInitial <= 122) {
      // turn them into numbers from 0 to 25
      firstInitial -= 97;
      lastInitial -= 97;
      // map them to a value from 0 to 255
      firstInitial *= (255.0 / 25.0);
      lastInitial *= (255.0 / 25.0);
    } 

    // In case the contact's initials aren't found in a-z or A-Z
    else {
      firstInitial = (int)random(255);
      lastInitial = (int)random(255);
    }

    frameR = 255 - firstInitial;
    frameG = lastInitial;
    frameB = (firstInitial + lastInitial) / 2;
  }

  // Draw the frame of the visual
  rectMode(CORNER);
  yMod = 10;
  fill(frameR, frameG, frameB);
  rect((-1), (-1), width + 1, height + 1);
}


// --------------------------------------------------------------------------------------//
// This function colours the background of the visual based on when the message was sent //
// --------------------------------------------------------------------------------------//

void colourBackground(int hour) {

  // Middle of night (12:00AM - 4:59AM)
  if (hour <= 4) {
    backgroundR = 30;
    backgroundG = 30;
    backgroundB = 35;
  }

  // Dawn (5:00AM - 7:59AM)
  else if (hour >= 5 && hour <= 7) {
    backgroundR = 255;
    backgroundG = 208;
    backgroundB = 112;
  }

  // Morning (8:00AM - 10:59AM)
  else if (hour >= 8 && hour <= 10) {
    backgroundR = 153;
    backgroundG = 204;
    backgroundB = 255;
  }

  // Midday (11:00AM - 5:59PM)
  else if (hour >= 11 && hour <= 17) {
    backgroundR = 0;
    backgroundG = 128;
    backgroundB = 255;
  }

  // Evening (6:00PM - 8:59PM)
  else if (hour >= 18 && hour <= 20) {
    backgroundR = 0;
    backgroundG = 76;
    backgroundB = 153;
  }

  // Nighttime (9:00PM - 11:55PM)
  else if (hour >= 21 && hour <= 24) {
    backgroundR = 0;
    backgroundG = 51;
    backgroundB = 102;
  }

  // Draw the background of the visual
  rectMode(CORNER);
  fill(backgroundR, backgroundG, backgroundB, 200);
  rect(0 + xMod, 0 + yMod, width - xMod * 2, height - yMod * 2);
}


// ----------------------------------------------------------------------------------------//
// This function draws boxes to represent letter frequency in the sent or received message //
// ----------------------------------------------------------------------------------------//

void drawMessageBoxes(String text) {

  letterFrequency(text);

  // Draw sent messages
  if (receivedOrSent[currentMessage].matches("Sent")) {

    rectMode(CORNERS);
    fill(frameR, frameG, frameB, 200);
    int xVal = 18;
    float xValPlus = 14;
    int multiplier = 20;

    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (a * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (b * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (c * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (d * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (e * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (f * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (g * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (h * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (i * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (j * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (k * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (l * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (m * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (n * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (o * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (p * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (q * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (r * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (s * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (t * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (u * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (v * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (w * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (x * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (y * multiplier)); 
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (z * multiplier));
  }

  // Draw received messages
  else {

    rectMode(CORNERS);
    fill(frameR, frameG, frameB, 200);
    int xVal = 18;
    float xValPlus = 14;
    int multiplier = 20;

    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (a * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (b * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (c * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (d * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (e * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (f * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (g * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (h * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (i * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (j * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (k * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (l * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (m * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (n * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (o * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (p * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (q * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (r * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (s * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (t * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (u * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (v * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (w * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (x * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (y * multiplier)); 
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (z * multiplier));
  }
}

// ---------------------------------------------------------------------------------//
//  This function calculates the most frequently used letter in the passed message  //
// ---------------------------------------------------------------------------------//

void letterFrequency (String text) {

  a = 0;
  b = 0;
  c = 0;
  d = 0;
  e = 0;
  f = 0;
  g = 0;
  h = 0;
  i = 0;
  j = 0;
  k = 0;
  l = 0;
  m = 0;
  n = 0;
  o = 0;
  p = 0;
  q = 0;
  r = 0;
  s = 0;
  t = 0;
  u = 0;
  v = 0;
  w = 0;
  x = 0;
  y = 0;
  z = 0;

  // Count how many times each letter is used per message
  for (int i = 0; i < text.length(); i++) {
    if (text.charAt(i) == 'a' || text.charAt(i) == 'A') a++;
    else if (text.charAt(i) == 'b' || text.charAt(i) == 'B') b++;
    else if (text.charAt(i) == 'c' || text.charAt(i) == 'C') c++;
    else if (text.charAt(i) == 'd' || text.charAt(i) == 'D') d++;
    else if (text.charAt(i) == 'e' || text.charAt(i) == 'E') e++;
    else if (text.charAt(i) == 'f' || text.charAt(i) == 'F') f++;
    else if (text.charAt(i) == 'g' || text.charAt(i) == 'G') g++;
    else if (text.charAt(i) == 'h' || text.charAt(i) == 'H') h++;
    else if (text.charAt(i) == 'i' || text.charAt(i) == 'I') i++;
    else if (text.charAt(i) == 'j' || text.charAt(i) == 'J') j++;
    else if (text.charAt(i) == 'k' || text.charAt(i) == 'K') k++;
    else if (text.charAt(i) == 'l' || text.charAt(i) == 'L') l++;
    else if (text.charAt(i) == 'm' || text.charAt(i) == 'M') m++;
    else if (text.charAt(i) == 'n' || text.charAt(i) == 'N') n++;
    else if (text.charAt(i) == 'o' || text.charAt(i) == 'O') o++;
    else if (text.charAt(i) == 'p' || text.charAt(i) == 'P') p++;
    else if (text.charAt(i) == 'q' || text.charAt(i) == 'Q') q++;
    else if (text.charAt(i) == 'r' || text.charAt(i) == 'R') r++;
    else if (text.charAt(i) == 's' || text.charAt(i) == 'S') s++;
    else if (text.charAt(i) == 't' || text.charAt(i) == 'T') t++;
    else if (text.charAt(i) == 'u' || text.charAt(i) == 'U') u++;
    else if (text.charAt(i) == 'v' || text.charAt(i) == 'V') v++;
    else if (text.charAt(i) == 'w' || text.charAt(i) == 'W') w++;
    else if (text.charAt(i) == 'x' || text.charAt(i) == 'X') x++;
    else if (text.charAt(i) == 'y' || text.charAt(i) == 'Y') y++;
    else if (text.charAt(i) == 'z' || text.charAt(i) == 'Z') z++;
  }

  mostFrequentCount = 0;
  mostFrequentLetter = "";

  // Figure out what the most frequently used letter is
  if (a > mostFrequentCount) { 
    mostFrequentCount = a; 
    mostFrequentLetter = "a";
  }
  if (b > mostFrequentCount) { 
    mostFrequentCount = b;
    mostFrequentLetter = "b";
  }
  if (c > mostFrequentCount) { 
    mostFrequentCount = c; 
    mostFrequentLetter = "c";
  }
  if (d > mostFrequentCount) { 
    mostFrequentCount = d; 
    mostFrequentLetter = "d";
  }
  if (e > mostFrequentCount) { 
    mostFrequentCount = e; 
    mostFrequentLetter = "e";
  }
  if (f > mostFrequentCount) { 
    mostFrequentCount = f; 
    mostFrequentLetter = "f";
  }
  if (g > mostFrequentCount) { 
    mostFrequentCount = g; 
    mostFrequentLetter = "g";
  }
  if (h > mostFrequentCount) { 
    mostFrequentCount = h; 
    mostFrequentLetter = "h";
  }
  if (i > mostFrequentCount) { 
    mostFrequentCount = i; 
    mostFrequentLetter = "i";
  }
  if (j > mostFrequentCount) { 
    mostFrequentCount = j; 
    mostFrequentLetter = "j";
  }
  if (k > mostFrequentCount) { 
    mostFrequentCount = k; 
    mostFrequentLetter = "k";
  }
  if (l > mostFrequentCount) { 
    mostFrequentCount = l; 
    mostFrequentLetter = "l";
  }
  if (m > mostFrequentCount) { 
    mostFrequentCount = m; 
    mostFrequentLetter = "m";
  }
  if (n > mostFrequentCount) { 
    mostFrequentCount = n; 
    mostFrequentLetter = "n";
  }
  if (o > mostFrequentCount) { 
    mostFrequentCount = o; 
    mostFrequentLetter = "o";
  }
  if (p > mostFrequentCount) { 
    mostFrequentCount = p; 
    mostFrequentLetter = "p";
  }
  if (q > mostFrequentCount) { 
    mostFrequentCount = q; 
    mostFrequentLetter = "q";
  }
  if (r > mostFrequentCount) { 
    mostFrequentCount = r; 
    mostFrequentLetter = "r";
  }
  if (s > mostFrequentCount) { 
    mostFrequentCount = s; 
    mostFrequentLetter = "s";
  }
  if (t > mostFrequentCount) { 
    mostFrequentCount = t; 
    mostFrequentLetter = "t";
  }
  if (u > mostFrequentCount) { 
    mostFrequentCount = u; 
    mostFrequentLetter = "u";
  }
  if (v > mostFrequentCount) { 
    mostFrequentCount = v; 
    mostFrequentLetter = "v";
  }
  if (w > mostFrequentCount) { 
    mostFrequentCount = w; 
    mostFrequentLetter = "w";
  }
  if (x > mostFrequentCount) { 
    mostFrequentCount = x; 
    mostFrequentLetter = "x";
  }
  if (y > mostFrequentCount) { 
    mostFrequentCount = y; 
    mostFrequentLetter = "y";
  }
  if (z > mostFrequentCount) { 
    mostFrequentCount = z; 
    mostFrequentLetter = "z";
  }
}

// ------------------------------------------------------------------------------------------------//
//  This function generates a note based on the most frequently used letter in the passed message  //
// ------------------------------------------------------------------------------------------------//

void createTones(String text) {

  // Set the attack, sustain, and release of the note
  float attackTime = 0.01;
  float sustainTime = 0.00001 * text.length();
  float sustainLevel = 0.0008 * mostFrequentCount;
  float releaseTime = 0.1;

  // Set which note to play
  int noteToPlay = 0;

  if (mostFrequentLetter == "a") {
    noteToPlay = 60;
  } else if (mostFrequentLetter == "b") {
    noteToPlay = 61;
  } else if (mostFrequentLetter == "c") {
    noteToPlay = 62;
  } else if (mostFrequentLetter == "d") {
    noteToPlay = 63;
  } else if (mostFrequentLetter == "e") {
    noteToPlay = 64;
  } else if (mostFrequentLetter == "f") {
    noteToPlay = 65;
  } else if (mostFrequentLetter == "g") {
    noteToPlay = 66;
  } else if (mostFrequentLetter == "h") {
    noteToPlay = 67;
  } else if (mostFrequentLetter == "i") {
    noteToPlay = 68;
  } else if (mostFrequentLetter == "j") {
    noteToPlay = 69;
  } else if (mostFrequentLetter == "k") {
    noteToPlay = 70;
  } else if (mostFrequentLetter == "l") {
    noteToPlay = 71;
  } else if (mostFrequentLetter == "m") {
    noteToPlay = 72;
  } else if (mostFrequentLetter == "n") {
    noteToPlay = 73;
  } else if (mostFrequentLetter == "o") {
    noteToPlay = 74;
  } else if (mostFrequentLetter == "p") {
    noteToPlay = 75;
  } else if (mostFrequentLetter == "q") {
    noteToPlay = 76;
  } else if (mostFrequentLetter == "r") {
    noteToPlay = 77;
  } else if (mostFrequentLetter == "s") {
    noteToPlay = 78;
  } else if (mostFrequentLetter == "t") {
    noteToPlay = 79;
  } else if (mostFrequentLetter == "u") {
    noteToPlay = 80;
  } else if (mostFrequentLetter == "v") {
    noteToPlay = 81;
  } else if (mostFrequentLetter == "w") {
    noteToPlay = 82;
  } else if (mostFrequentLetter == "x") {
    noteToPlay = 83;
  } else if (mostFrequentLetter == "y") {
    noteToPlay = 84;
  } else if (mostFrequentLetter == "z") {
    noteToPlay = 85;
  }

  // Play the note
  float midiToFreq = (pow(2, ((noteToPlay - 69) / 12.0))) * 440;
  triOsc.play(midiToFreq, (text.length() * 0.2));
  env.play(triOsc, attackTime, sustainTime, sustainLevel, releaseTime);
}
