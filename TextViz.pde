import processing.sound.*;

// TextViz by Daniel James

TriOsc triOsc;
Env env; 

// Times and levels for the ASR envelope
float attackTime = 0.001;
float sustainTime = 0.004;
float sustainLevel = 0.2;
float releaseTime = 0.2;

// This is an octave in MIDI notes.
int[] midiSequence = { 
  60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72
}; 

// Set the duration between the notes
int duration = 200;
// Set the note trigger
int trigger = 0; 

// An index to count up the notes
int note = 0; 


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

int currentMessage = 1;

// Arrays
String[] receivedOrSentA;
String[] phoneNumberA;
String[] contactNameA;
int[] hourA;
String[] messageContentA;

// Temporary variables for setup()
String receivedOrSent;
String phoneNumber;
String contactName;
int hour;
String messageContent;
int maxMessageSize;

void setup() {
  size(400, 700);
  smooth();
  

  // Create triangle wave and envelope 
  triOsc = new TriOsc(this);
  env  = new Env(this);
  
  
  

  data = loadTable("SMS2.csv", "header");


  rowCount = data.getRowCount();

  // The spreadsheet is set up in a long column with groups of 5
  // 1 - "Received" or "Sent"
  // 2 - Phone number
  // 3 - Contact name
  // 4 - Timestamp
  // 5 - Message content
  receivedOrSentA  = new String[(rowCount / 5)];
  phoneNumberA = new String[(rowCount / 5)];
  contactNameA = new String[(rowCount / 5)];
  hourA = new int[(rowCount / 5)];
  messageContentA = new String[(rowCount / 5)];

  maxMessageSize = 0;

  // Iterate through the .csv file and add the data into arrays so that we can access them from draw() without having to iterate every time
  for (int i = 0; i < rowCount; i++) {
    if (i % 5 == 0) {

      // Received or Sent
      receivedOrSent = data.getRow(i).getString("message");

      // Phone number
      phoneNumber = data.getRow(i + 1).getString("message");

      // Contact name
      contactName = data.getRow(i + 2).getString("message");

      // Hour of day
      String[] timeStampSplit = splitTokens(data.getRow(i + 3).getString("message"), " ");
      String[] timeSplit = splitTokens(timeStampSplit[1], ":");
      hour = parseInt(timeSplit[0]);

      // Message content
      messageContent = data.getRow(i + 4).getString("message");

      // Populate arrays
      receivedOrSentA[i/5] = receivedOrSent;
      phoneNumberA[i/5] = phoneNumber;
      contactNameA[i/5] = contactName;
      hourA[i/5] = hour;
      messageContentA[i/5] = messageContent;

      if (messageContent.length() > maxMessageSize) maxMessageSize = messageContent.length();

      //println(receivedOrSent + ": " + contactName + "(" + phoneNumber + ") at " + hour + "h: " + messageContent);
    }
  }
}



// This function calculates the respective frequency of a MIDI note
float midiToFreq(int note) {
  return (pow(2, ((note-69)/12.0)))*440;
}



void draw() {

    // If value of trigger is equal to the computer clock and if not all 
  // notes have been played yet, the next note gets triggered.
  if ((millis() > trigger) && (note<midiSequence.length)) {

    // midiToFreq transforms the MIDI value into a frequency in Hz which we use 
    //to control the triangle oscillator with an amplitute of 0.8
    triOsc.play(midiToFreq(midiSequence[note]), 0.8);

    // The envelope gets triggered with the oscillator as input and the times and 
    // levels we defined earlier
    env.play(triOsc, attackTime, sustainTime, sustainLevel, releaseTime);

    // Create the new trigger according to predefined durations and speed
    trigger = millis() + duration;

    // Advance by one note in the midiSequence;
    note++; 

    // Loop the sequence
    if (note == 12) {
      note = 0;
    }
  }

  
  
  
  
  noStroke();
  // Draw the frame
  colourFrame(contactNameA[currentMessage]);

  // Draw the background colour
  colourBackground(hourA[currentMessage]);

  // Draw the boxes
  messageAnalysis(messageContentA[currentMessage]);

  //fill(255);
  //textAlign(CENTER);
  //text("TEST", width/2, height/2);

  currentMessage++;

  // Reset when the last message is reached
  if (currentMessage == (rowCount / 5)) {

    currentMessage = 1;

    // Draw the frame
    colourFrame(contactNameA[currentMessage]);

    // Draw the background colour
    colourBackground(hourA[currentMessage]);
    //textMode(CENTER);
    fill(255);
    textAlign(CENTER);
    textSize(25);
    text("RESTARTING", width/2, height/2);
    delay(100000000);
  }

  //delay(100);
}




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
      firstInitial *= (255. / 25.);
      lastInitial *= (255. / 25.);
    }

    // Assign the first initial (A - Z) a number from 0 - 255
    else if (firstInitial >= 97 && firstInitial <= 122 && lastInitial >= 97 && lastInitial <= 122) {
      // turn them into numbers from 0 to 25
      firstInitial -= 97;
      lastInitial -= 97;
      // map them to a value from 0 to 255
      firstInitial *= (255. / 25.);
      lastInitial *= (255. / 25.);
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
  rectMode(CORNER);
  yMod = 10;
  //stroke(frameR, frameG, frameB);
  fill(frameR, frameG, frameB);
  rect((-1), (-1), width + 1, height + 1);
}






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

  // Draw the background
  rectMode(CORNER);
  fill(backgroundR, backgroundG, backgroundB, 200);
  rect(0 + xMod, 0 + yMod, width - xMod * 2, height - yMod * 2);
}














int a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z, punctuation, other;
int zero, one, two, three, four, five, six, seven, eight, nine;


void messageAnalysis(String text) {
  //println(text);
  //println(maxMessageSize);
  //double maxHeight = maxMessageSize / (height / 2) ;
  //println("maxHeight = " + maxHeight);
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

  punctuation = 0;

  zero = 0;
  one = 0;
  two = 0;
  three = 0;
  four = 0;
  five = 0;
  six = 0;
  seven = 0;
  eight = 0;
  nine = 0;

  other = 0;

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
    else if (text.charAt(i) == '0') zero++;
    else if (text.charAt(i) == '1') one++;
    else if (text.charAt(i) == '2') two++;
    else if (text.charAt(i) == '3') three++;
    else if (text.charAt(i) == '4') four++;
    else if (text.charAt(i) == '5') five++;
    else if (text.charAt(i) == '6') six++;
    else if (text.charAt(i) == '7') seven++;
    else if (text.charAt(i) == '8') eight++;
    else if (text.charAt(i) == '9') nine++;
    else if (text.charAt(i) == '.' || text.charAt(i) == ',' || text.charAt(i) == ' ') punctuation++;
    else other++;
  }

  int mostFrequentCount = 0;
  String mostFrequentLetter = "";

  //println("a: " + a);  println("b: " + b);  println("c: " + c);  println("d: " + d);  println("e: " + e);  println("f: " + f);
  //println("g: " + g);  println("h: " + h);  println("i: " + i);  println("j: " + j);  println("k: " + k);  println("l: " + l);
  //println("m: " + m);  println("n: " + n);  println("o: " + o);  println("p: " + p);  println("q: " + q);  println("r: " + r);
  //println("s: " + s);  println("t: " + t);  println("u: " + u);  println("v: " + v);  println("w: " + w);  println("x: " + x);
  //println("y: " + y);  println("z: " + z);  println("one: " + one);  println("two: " + two);  println("three: " + three);
  //println("four: " + four);  println("five: " + five);  println("six: " + six);  println("seven: " + seven);  println("eight: " + eight);
  //println("nine: " + nine);  println("zero: " + zero);  println("other: " + other);  println("punctuation: " + punctuation);


  if (a > mostFrequentCount) { mostFrequentCount = a; mostFrequentLetter = "a"; }
  if (b > mostFrequentCount) { mostFrequentCount = b; mostFrequentLetter = "b"; }
  if (c > mostFrequentCount) { mostFrequentCount = c; mostFrequentLetter = "c"; }
  if (d > mostFrequentCount) { mostFrequentCount = d; mostFrequentLetter = "d"; }
  if (e > mostFrequentCount) { mostFrequentCount = e; mostFrequentLetter = "e"; }
  if (f > mostFrequentCount) { mostFrequentCount = f; mostFrequentLetter = "f"; }
  if (g > mostFrequentCount) { mostFrequentCount = g; mostFrequentLetter = "g"; }
  if (h > mostFrequentCount) { mostFrequentCount = h; mostFrequentLetter = "h"; }
  if (i > mostFrequentCount) { mostFrequentCount = i; mostFrequentLetter = "i"; }
  if (j > mostFrequentCount) { mostFrequentCount = j; mostFrequentLetter = "j"; }
  if (k > mostFrequentCount) { mostFrequentCount = k; mostFrequentLetter = "k"; }
  if (l > mostFrequentCount) { mostFrequentCount = l; mostFrequentLetter = "l"; }
  if (m > mostFrequentCount) { mostFrequentCount = m; mostFrequentLetter = "m"; }
  if (n > mostFrequentCount) { mostFrequentCount = n; mostFrequentLetter = "n"; }
  if (o > mostFrequentCount) { mostFrequentCount = o; mostFrequentLetter = "o"; }
  if (p > mostFrequentCount) { mostFrequentCount = p; mostFrequentLetter = "p"; }
  if (q > mostFrequentCount) { mostFrequentCount = q; mostFrequentLetter = "q"; }
  if (r > mostFrequentCount) { mostFrequentCount = r; mostFrequentLetter = "r"; }
  if (s > mostFrequentCount) { mostFrequentCount = s; mostFrequentLetter = "s"; }
  if (t > mostFrequentCount) { mostFrequentCount = t; mostFrequentLetter = "t"; }
  if (u > mostFrequentCount) { mostFrequentCount = u; mostFrequentLetter = "u"; }
  if (v > mostFrequentCount) { mostFrequentCount = v; mostFrequentLetter = "v"; }
  if (w > mostFrequentCount) { mostFrequentCount = w; mostFrequentLetter = "w"; }
  if (x > mostFrequentCount) { mostFrequentCount = x; mostFrequentLetter = "x"; }
  if (y > mostFrequentCount) { mostFrequentCount = y; mostFrequentLetter = "y"; }
  if (z > mostFrequentCount) { mostFrequentCount = z; mostFrequentLetter = "z"; }

  //if (one > mostFrequentCount) { mostFrequentCount = one; }
  //if (two > mostFrequentCount) { mostFrequentCount = two; }
  //if (three > mostFrequentCount) { mostFrequentCount = three; }
  //if (four > mostFrequentCount) { mostFrequentCount = four; }
  //if (five > mostFrequentCount) { mostFrequentCount = five; }
  //if (six > mostFrequentCount) { mostFrequentCount = six; }
  //if (seven > mostFrequentCount) { mostFrequentCount = seven; }
  //if (eight > mostFrequentCount) { mostFrequentCount = eight; }
  //if (nine > mostFrequentCount) { mostFrequentCount = nine; }
  //if (zero > mostFrequentCount) { mostFrequentCount = zero; }
  //if (other > mostFrequentCount) { mostFrequentCount = other; }
  //if (punctuation > mostFrequentCount) { mostFrequentCount = punctuation; }

  println("MFL ====== ");
  println(mostFrequentLetter + ": " + mostFrequentCount);
  println(" ");




  if (receivedOrSentA[currentMessage].matches("Sent")) {

    rectMode(CORNERS);
    fill(frameR, frameG, frameB, 200);
    int xVal = 22;
    float xValPlus = 13.5;
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
    xVal += xValPlus;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (other * multiplier));
    xVal += xValPlus;

    xVal = 22;
    xValPlus = 25;
    multiplier = 30;

    fill(frameR, frameG, frameB, 180);

    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (zero * multiplier));
    xVal += 35;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (one * multiplier));
    xVal += 35;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (two * multiplier));
    xVal += 35;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (three * multiplier));
    xVal += 35;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (four * multiplier));
    xVal += 35;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (five * multiplier));
    xVal += 35;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (six * multiplier));
    xVal += 35;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (seven * multiplier));
    xVal += 35;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (eight * multiplier));
    xVal += 35;
    rect(xVal, height - yMod, xVal + xValPlus, (height - yMod) - (nine * multiplier));
  }

  // Draw received messages
  else {
    rectMode(CORNERS);
    fill(frameR, frameG, frameB, 200);
    int xVal = 22;
    float xValPlus = 13.5;
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
    xVal += xValPlus;
    rect(xVal, 0 + yMod, xVal + xValPlus, yMod + (other * multiplier));
    xVal += xValPlus;

    xVal = 22;
    xValPlus = 25;
    multiplier = 30;

    fill(frameR, frameG, frameB, 180);

    rect(xVal, yMod, xVal + xValPlus, yMod + (zero * multiplier));
    xVal += xValPlus;
    rect(xVal, yMod, xVal + xValPlus, yMod + (one * multiplier));
    xVal += xValPlus;
    rect(xVal, yMod, xVal + xValPlus, yMod + (two * multiplier));
    xVal += xValPlus;
    rect(xVal, yMod, xVal + xValPlus, yMod + (three * multiplier));
    xVal += xValPlus;
    rect(xVal, yMod, xVal + xValPlus, yMod + (four * multiplier));
    xVal += xValPlus;
    rect(xVal, yMod, xVal + xValPlus, yMod + (five * multiplier));
    xVal += xValPlus;
    rect(xVal, yMod, xVal + xValPlus, yMod + (six * multiplier));
    xVal += xValPlus;
    rect(xVal, yMod, xVal + xValPlus, yMod + (seven * multiplier));
    xVal += xValPlus;
    rect(xVal, yMod, xVal + xValPlus, yMod + (eight * multiplier));
    xVal += xValPlus;
    rect(xVal, yMod, xVal + xValPlus, yMod + (nine * multiplier));
  }

  int delayTime = text.length();

  //// Shortest message
  //if (text.length() < 5) {
  //  delayTime = 10;
  //}

  //// Medium length message
  //else if (text.length() >= 5 && text.length() <= 25) {
  //  delayTime = 25;
  //}

  //// Long message
  //else if (text.length() >= 26 && text.length() <= 50) {
  //  delayTime = 50;
  //} 

  //// Longer message
  //else if (text.length() >= 51 && text.length() <= 80) {
  //  delayTime = 100;
  //} 

  //// Longest message
  //else if (text.length() > 80) {
  //  delayTime = 200;
  //} 

  //// Normalize weird numbers
  //else {
  //  delayTime = 25;
  //}


  //delay(delayTime);






  //rectMode(CORNERS);
  //fill(frameR, frameG, frameB);
  //rect((width / 2), height, drawSize, drawSize);



  //if (text.length() > maxLength) maxLength = text.length();


  //println("Max length: " + maxLength);
}