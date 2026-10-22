/*
  Xander Thomson
  Final Processing Project
  
  TODO: A 3-stage STG that mainly focuses on bosses (stages are basically intermissions)
*/

// Player variables
short p1X = 100, p1Y = 350, p2X = 300, p2Y = 350; // P1/2 positions
byte p1OX = 0, p1OY = 0, p2OX = 0, p2OY = 0; // P1/2 option offsets
byte p1OMag = 0, p2OMag = 0; // P1/2 option distance from player when they respawn

byte p1IFrames = 0;
byte p2IFrames = 0;

/*
  01234567
  
  0-1: Unused
  2: P1 playing?
  3: P2 playing?
  4: P1 moving horizontally
  5: P1 moving vertically
  6: P2 moving horizontally
  7: P2 moving vertically
*/
byte plyManagement = 0;


// Timer variables
long timer = 0;
boolean frameType = false; // For 30 FPS operations


// Misc variables
boolean refreshing = false;


void setup() {
  size(400, 400);
  //noSmooth();
  
  refresh();
}


void draw() {
  timer = System.nanoTime();
  frameType = !frameType;
  
  refreshing = false;
  
  
  // P1 Controls
  if ((plyManagement & 0b1000000) == 0) {
    
    // Wait for Start to be pressed
    if ((conA & 0b1) == 0b1) {
      plyManagement += 0b1000000;
      refreshing = true;
    }
    
  } else {
    
    // P1 option magnitude management
    if (p1OMag < 25) {p1OMag++; refreshing = true;}
    
    // Controls
    if ((conA & 0b10000000) == 0b10000000) {
      p1Y -= (plyManagement & 0b1000) == 0b1000 ? 3 : (frameType ? 4 : 3);
      if ((plyManagement & 0b100) == 0)
        plyManagement += 0b100;
      refreshing = true;
    } else if ((conA & 0b1000000) != 0b1000000 && (plyManagement & 0b100) == 0b100)
      plyManagement -= 0b100;
    
    if ((conA & 0b1000000) == 0b1000000) {
      p1Y += (plyManagement & 0b1000) == 0b1000 ? 3 : (frameType ? 4 : 3);
      if ((plyManagement & 0b100) == 0)
        plyManagement += 0b100;
      refreshing = true;
    } else if ((conA & 0b10000000) != 0b10000000 && (plyManagement & 0b100) == 0b100)
      plyManagement -= 0b100;
    
    if ((conA & 0b100000) == 0b100000) {
      p1X -= (plyManagement & 0b100) == 0b100 ? (frameType ? 4 : 3) : (frameType ? 5 : 4);
      if ((plyManagement & 0b1000) == 0)
        plyManagement += 0b1000;
      refreshing = true;
    } else if ((conA & 0b1000) != 0b10000 && (plyManagement & 0b1000) == 0b1000)
      plyManagement -= 0b1000;
    
    if ((conA & 0b10000) == 0b10000) {
      p1X += (plyManagement & 0b100) == 0b100 ? (frameType ? 4 : 3) : (frameType ? 5 : 4);
      if ((plyManagement & 0b1000) == 0)
        plyManagement += 0b1000;
      refreshing = true;
    } else if ((conA & 0b100000) != 0b100000 && (plyManagement & 0b1000) == 0b1000)
      plyManagement -= 0b1000;
    
  }
  
  
  // P2 Controls
  if ((plyManagement & 0b100000) == 0) {
    
    // Wait for Start to be pressed
    if ((conB & 0b1) == 0b1) {
      plyManagement += 0b100000;
      refreshing = true;
    }
    
  } else {
    
    // P2 option magnitude management
    if (p2OMag < 25) {p2OMag++; refreshing = true;}
    
    // Controls
    if ((conB & 0b10000000) == 0b10000000) {
      p2Y -= (plyManagement & 0b10) == 0b10 ? 3 : (frameType ? 4 : 3);
      if ((plyManagement & 0b1) == 0)
        plyManagement += 0b1;
      refreshing = true;
    } else if ((conB & 0b1000000) != 0b1000000 && (plyManagement & 0b1) == 0b1)
      plyManagement -= 0b1;
    
    if ((conB & 0b1000000) == 0b1000000) {
      p2Y += (plyManagement & 0b10) == 0b10 ? 3 : (frameType ? 4 : 3);
      if ((plyManagement & 0b1) == 0)
        plyManagement += 0b1;
      refreshing = true;
    } else if ((conB & 0b10000000) != 0b10000000 && (plyManagement & 0b1) == 0b1)
      plyManagement -= 0b1;
    
    if ((conB & 0b100000) == 0b100000) {
      p2X -= (plyManagement & 0b1) == 0b1 ? 3 : 4;
      if ((plyManagement & 0b10) == 0)
        plyManagement += 0b10;
      refreshing = true;
    } else if ((conB & 0b10000) != 0b10000 && (plyManagement & 0b10) == 0b10)
      plyManagement -= 0b10;
    
    if ((conB & 0b10000) == 0b10000) {
      p2X += (plyManagement & 0b1) == 0b1 ? 3 : 4;
      if ((plyManagement & 0b10) == 0)
        plyManagement += 0b10;
      refreshing = true;
    } else if ((conB & 0b100000) != 0b100000 && (plyManagement & 0b1) == 0b10)
      plyManagement -= 0b10;
    
  }
  
  
  if (refreshing) refresh();
  
  // This should run just under 60 FPS
  try {Thread.sleep(17 - System.nanoTime() - timer / 1000000);} catch (InterruptedException e) {} catch (IllegalArgumentException e) {
    try {Thread.sleep(17);} catch (InterruptedException ex) {}
  }
}