/*
  Xander Thomson
  Final Processing Project
  
  TODO: A 3-stage STG that mainly focuses on bosses (stages are basically intermissions)
*/

/*
  This game is completely compatible with two players, however I would very much advise
  connecting another keyboard if you actually plan on testing this, due to the key press
  detection limitations most keyboards have.
*/

import java.util.concurrent.TimeUnit;

// It'd be really neat if final/const variables that contain literals were just compiled as literals instead of stored in memory
// They don't really need to be in memory if you think about it, everything should still work perfectly that way
// I guess C++ does that with #define

// Shot types
final byte LSHOT = 0; // Linear shot (P1 main)
final byte LOMSHOT = 1; // Linear middle option shot (P1 option)
final byte LOLNSHOT = 2; // Linear near left option shot (P1 option)
final byte LOLFSHOT = 3; // Linear far left option shot (P1 option)
final byte LORNSHOT = 4; // Linear near right option shot (P1 option)
final byte LORFSHOT = 5; // Linear far right option shot (P1 option)
final byte WMSHOT = 6; // Wide middle shot (P2 main)
final byte WLSHOT = 7; // Wide left shot (P2 main)
final byte WRSHOT = 8; // Wide right shot (P2 main)
final byte WOMSHOT = 9; // Wide middle shot (P2 option)
final byte WOLSHOT = 10; // Wide left option shot (P2 option)
final byte WORSHOT = 11; // Wide right option shot (P2 option)

// Bullet types
final byte B_ORANGEBALL = 0;
final byte B_PINKBALL = 1;
final byte B_BLUEBALL = 2;
final byte B_ORANGESPIKE = 3;
final byte B_PINKSPIKE = 4;
final byte B_BLUESPIKE = 5;
final byte B_YELLOWLARGE = 6;
final byte B_BOMB = 7;


// Font variables
PFont smallText;
PFont bigText;


// Player variables
short p1X = 100, p1Y = 350, p2X = 300, p2Y = 350; // P1/2 positions

short p1BombX, p1BombY, p1BombSize;

short p2BombOriginX, p2BombOriginY;

byte p1OX = 0, p1OY = 0, p2OX = 0, p2OY = 0; // P1/2 option offsets
byte p1OMag = 0, p2OMag = 0; // P1/2 option distance from player when they respawn

byte p1IFrames = 0, p2IFrames = 0;

byte p1ShotCount = 0, p2ShotCount = 0;


/*
  01234567
  
  0: P2 exists?
  1: P1 exists?
  2-4: P2 stocks (0-7)
  5-7: P1 stocks (0-7)
*/
byte stocks = 0;

/*
  01234567
  
  0-3: P2 respawn time (0-15)
  4-7: P1 respawn time (0-15)
*/
byte respawnTime = 0;

/*
  01234567
  
  0-3: P2 bomb ticks left (0-15)
  4-5: P1 bombs (0-3)
  6-7: P2 bombs (0-3)
*/
byte bombs = 0;

/*
  01234567
  
  0-5: P1 bomb time (0-127)
  6: P1 bombing?
  7: P2 bombing?
*/
byte bombInfo = 0;

/*
  01234567
  
  0-3: P2 next shot (0-15)
  4-7: P1 next shot (0-15)
*/
byte nextShot = 0;

/*
  01234567
  
  0: P1 options ready?
  1: P2 options ready?
  2: P1 playing?
  3: P2 playing?
  4: P1 moving horizontally
  5: P1 moving vertically
  6: P2 moving horizontally
  7: P2 moving vertically
*/
byte plyManagement = 0;


// Bullet variables
short bulletCount = 0;


// Timer variables
long timer = 0;
int simulatedFrames = 0; // frameCount will continue whether or not the game is paused, which makes sense
boolean frameType = false; // For 30 FPS operations
boolean subFrameType = false; // For 15 FPS operations
boolean subSubFrameType = false; // For 7.5 FPS operations


// Menu variables
byte menuItem;

/*
  01234567
  
  0-4: Unused
  5: Can select
  6: Can go up
  7: Can go down
*/
byte canGo;

boolean inTitle = true;


// Misc variables
String centerText = "";

long lastProcessTime = 0;

short timeUntilBossSpawn;

short centerTextTimer;
short centerTextX, centerTextY;

byte stage;

boolean spawningBoss;
boolean generallySpawningBosses = true;

boolean refreshing = false;

boolean pausePressed = false;
boolean paused = false;
boolean canPause = true;


// SET TO TRUE OR FALSE FOR SCREEN SIZE!
boolean scaledVisuals = true;

short winSize = (short) (scaledVisuals ? 800 : 400);


// Player arrays
short[] p1ShotX = new short[0];
short[] p1ShotY = new short[0];

short[] p2ShotX = new short[0];
short[] p2ShotY = new short[0];

short[] p2BombX = new short[0];
short[] p2BombY = new short[0];
short[] p2BombSize = new short[0];

byte[] p1ShotType = new byte[0];
byte[] p2ShotType = new byte[0];

byte[] p1ShotRemoval = new byte[0];
byte[] p2ShotRemoval = new byte[0];


// Bullet arrays
short[] bulletRemoval = new short[0];

float[] bulletX = new float[0];
float[] bulletY = new float[0];
float[] bulletDir = new float[0];
byte[] bulletSpd = new byte[0];
byte[] bulletType = new byte[0];
byte[] bulletSize = new byte[0];


// Enemy arrays
EnemyComp[] enemies = new EnemyComp[0];


// Menu arrays
String[] menuItems;


// General methods
double pointTo(short x1, short y1, short x2, short y2) {return Math.toDegrees(Math.atan2(x1 - x2, y1 - y2)) + 180;}

short plyX(boolean player) {return player ? (((stocks & 0b1000000) == 0b1000000) ? p1X : (((stocks & 0b10000000) == 0b10000000) ? p2X : p1X)) : (((stocks & 0b10000000) == 0b10000000) ? p2X : p1X);}
short plyY(boolean player) {return player ? (((stocks & 0b1000000) == 0b1000000) ? p1Y : (((stocks & 0b10000000) == 0b10000000) ? p2Y : p1Y)) : (((stocks & 0b10000000) == 0b10000000) ? p2Y : p1Y);}

// true = P1; false = P2
boolean nearestPlayer(short x, short y) {return ((stocks & 0b10000000) == 0b10000000) ? (((stocks & 0b1000000) == 0b1000000) ? (dist(x, y, p1X, p1Y) <= dist(x, y, p2X, p2Y)) : false) : true;}

boolean randomPlayer() {return ((stocks & 0b10000000) == 0b10000000) ? (((stocks & 0b1000000) == 0b1000000) ? (random(0, 2) == 1) : false) : true;}


// Initialization
void settings() {
  size(winSize, winSize);
}

void setup() {
  frameRate(Integer.MAX_VALUE); // I have implemented my own frame throttling system; I don't know if Processing accomodates for processing time by default
  //noSmooth();
  
  smallText = createFont("SansSerif", scaledVisuals ? 24 : 12);
  bigText = createFont("SansSerif", scaledVisuals ? 64 : 32);
  
  menuItems = new String[] {"Start", "Exit"};
  refresh();
}


// Per frame
void draw() {
  
  if (inTitle) {
    
    if (((conA & 0b10000000) == 0b10000000 || (conB & 0b10000000) == 0b10000000) && ((canGo & 0b10) == 0b10)) {
      canGo = (byte) (canGo & 0b11111101);
      if (menuItem > 0) {menuItem--; refreshing = true;}
    } else if (((conA & 0b10000000) == 0 && (conB & 0b10000000) == 0) && ((canGo & 0b10) == 0))
      canGo = (byte) (canGo | 0b10);
    
    if (((conA & 0b1000000) == 0b1000000 || (conB & 0b1000000) == 0b1000000) && ((canGo & 0b1) == 0b1)) {
      canGo = (byte) (canGo & 0b11111110);
      if (menuItem < menuItems.length - 1) {menuItem++; refreshing = true;}
    } else if (((conA & 0b1000000) == 0 && (conB & 0b1000000) == 0) && ((canGo & 0b1) == 0))
      canGo = (byte) (canGo | 0b1);
    
    if (((conA & 0b1000) == 0b1000 || (conB & 0b1000) == 0b1000) && ((canGo & 0b100) == 0b100)) {
      canGo = (byte) (canGo & 0b11111011);
      if (menuItems[menuItem].equals("Start")) {
        inTitle = false;
        refreshing = true;
      } else if (menuItems[menuItem].equals("Exit")) {
        System.exit(0);
      } else {
        println("Bogus menuItem: " + menuItems[menuItem]);
      }
    } else if (((conA & 0b1000) == 0 && (conB & 0b1000) == 0) && ((canGo & 0b100) == 0))
      canGo = (byte) (canGo | 0b100);
    
    if (refreshing) refresh();
    
    return;
    
  }
  
  if (paused) {
    refreshing = false;
    
    if (pausePressed && canPause) {
      paused = false;
      canPause = false;
      refresh();
    }
    else if (!pausePressed && !canPause)
      canPause = true;
    
    try {TimeUnit.NANOSECONDS.sleep(16666667 - (lastProcessTime));} catch (InterruptedException e) {} catch (IllegalArgumentException e) {
      try {TimeUnit.NANOSECONDS.sleep(16666667);} catch (InterruptedException ex) {}
    }
    
    return;
  }
  
  simulatedFrames++;
  
  timer = System.nanoTime();
  
  frameType = !frameType;
  if (frameType) {subFrameType = !subFrameType;}
  if (frameType && subFrameType) {subSubFrameType = !subSubFrameType;}
  
  refreshing = false;
  
  // Enemy actions
  for (short i = 0; i < enemies.length; i++) {
    if ((enemies[i].management & 0b100) >> 2 == 1) {removeEnemy(i--); continue;}
    
    // Check if this enemy is airborne
    if ((enemies[i].management & 0b10000) >> 4 == 1) {
      
      // Check if this airborne enemy is touching P1
      if (
        (plyManagement & 0b100000) == 0b100000 && // Playing?
        (stocks & 0b1000000) == 0b1000000 && // Existing?
        (p1IFrames < 1) && // Vulnerable?
        ( // Colliding?
          (p1X - 3 < enemies[i].getX() + enemies[i].boxWidth / 2 && p1X + 2 > enemies[i].getX() - enemies[i].boxWidth / 2) &&
          (p1Y - 3 < enemies[i].getY() + enemies[i].boxHeight / 2 && p1Y + 2 > enemies[i].getY() - enemies[i].boxHeight / 2)
        ) 
      ) {
        stocks = (byte) (stocks & 0b10111111); 
        respawnTime += 15;
      }
      
      // Check if this airborne enemy is touching P2
      if (
        (plyManagement & 0b10000) == 0b10000 && // Playing?
        (stocks & 0b10000000) == 0b10000000 && // Existing?
        (p2IFrames < 1) && // Vulnerable?
        ( // Colliding?
          (p2X - 3 < enemies[i].getX() + enemies[i].boxWidth / 2 && p2X + 2 > enemies[i].getX() - enemies[i].boxWidth / 2) &&
          (p2Y - 3 < enemies[i].getY() + enemies[i].boxHeight / 2 && p2Y + 2 > enemies[i].getY() - enemies[i].boxHeight / 2)
        ) 
      ) {
        stocks = (byte) (stocks & 0b1111111);
        respawnTime += 240; // 15 & 0b10000 = 240 (for binary reasons)
      }
      
    }
    
    // Do enemy actions
    enemies[i].resetTint();
    enemies[i].act();
  }
  
  // P1 Controls
  if ((plyManagement & 0b100000) == 0) {
    
    // Wait for Start to be pressed
    if ((conA & 0b1) == 0b1) {
      plyManagement += 0b100000;
      stocks += 3;
      refreshing = true;
      
      spawnPlayer(true);
    }
    
  } else {
    
    // P1 option magnitude management
    if ((plyManagement & 0b10000000) == 0) {
      if ((bombInfo & 0b10) == 0b10) {if (p1OMag > 0) {p1OMag--;}} else {p1OMag++;}
      refreshing = true;
      
      if (p1OMag >= 25) plyManagement += 0b10000000;
    }
    
    // Update nextShot this frame if needed
    if ((nextShot & 0b1111) > 0)
      nextShot--;
    
    // Controls
    
    // Go up
    if ((conA & 0b10000000) == 0b10000000) {
      
      p1Y -= (conA & 0b10) == 0b10 ? ((plyManagement & 0b1000) == 0b1000 ? (frameType ? 2 : 1) : 2) : ((plyManagement & 0b1000) == 0b1000 ? 3 : (frameType ? 4 : 3));
      if ((plyManagement & 0b100) == 0)
        plyManagement += 0b100;
      refreshing = true;
      
    } else if ((conA & 0b1000000) != 0b1000000 && (plyManagement & 0b100) == 0b100)
      plyManagement -= 0b100;
    
    // Go down
    if ((conA & 0b1000000) == 0b1000000) {
      
      p1Y += (conA & 0b10) == 0b10 ? ((plyManagement & 0b1000) == 0b1000 ? (frameType ? 2 : 1) : 2) : ((plyManagement & 0b1000) == 0b1000 ? 3 : (frameType ? 4 : 3));
      if ((plyManagement & 0b100) == 0)
        plyManagement += 0b100;
      refreshing = true;
      
    } else if ((conA & 0b10000000) != 0b10000000 && (plyManagement & 0b100) == 0b100)
      plyManagement -= 0b100;
    
    // Go left
    if ((conA & 0b100000) == 0b100000) {
      
      p1X -= (conA & 0b10) == 0b10 ? ((plyManagement & 0b100) == 0b100 ? (frameType ? 3 : 2) : 3) : ((plyManagement & 0b100) == 0b100 ? (frameType ? 4 : 3) : (frameType ? 5 : 4));
      if ((plyManagement & 0b1000) == 0)
        plyManagement += 0b1000;
      refreshing = true;
      
    } else if ((conA & 0b1000) != 0b10000 && (plyManagement & 0b1000) == 0b1000)
      plyManagement -= 0b1000;
    
    // Go right
    if ((conA & 0b10000) == 0b10000) {
      
      p1X += (conA & 0b10) == 0b10 ? ((plyManagement & 0b100) == 0b100 ? (frameType ? 3 : 2) : 3) : ((plyManagement & 0b100) == 0b100 ? (frameType ? 4 : 3) : (frameType ? 5 : 4));
      if ((plyManagement & 0b1000) == 0)
        plyManagement += 0b1000;
      refreshing = true;
      
    } else if ((conA & 0b100000) != 0b100000 && (plyManagement & 0b1000) == 0b1000)
      plyManagement -= 0b1000;
    
    // Shoot
    if ((stocks & 0b1000000) == 0b1000000 && (conA & 0b1000) == 0b1000 && (nextShot & 0b1111) < 1 && p1ShotCount < 21) {
      
      addPlayerShot(p1X, p1Y, (byte) 0, true); // Why can't Java have short or byte literals? Same goes for C
      addPlayerShot((short) (p1X - 7), (short) (p1Y + 4), (byte) LSHOT, true);
      addPlayerShot((short) (p1X + 7), (short) (p1Y + 4), (byte) LSHOT, true);
      
      if ((plyManagement & 0b10000000) == 0b10000000) {
        if ((conA & 0b10) == 0b10) {
          // Focus fire
          addPlayerShot((short) (p1X - 13), (short) (p1Y + 6), (byte) LOMSHOT, true);
          addPlayerShot((short) (p1X + 13), (short) (p1Y + 6), (byte) LOMSHOT, true);
          addPlayerShot((short) (p1X - 19), (short) (p1Y + 10), (byte) LOMSHOT, true);
          addPlayerShot((short) (p1X + 19), (short) (p1Y + 10), (byte) LOMSHOT, true);
        } else {
          // Standard fire
          addPlayerShot((short) (p1X - 13), (short) (p1Y + 6), (byte) LOLNSHOT, true);
          addPlayerShot((short) (p1X + 13), (short) (p1Y + 6), (byte) LORNSHOT, true);
          addPlayerShot((short) (p1X - 19), (short) (p1Y + 10), (byte) LOLFSHOT, true);
          addPlayerShot((short) (p1X + 19), (short) (p1Y + 10), (byte) LORFSHOT, true);
        }
      }
      
      nextShot += (conA & 0b10) == 0b10 ? 4 : 5; // If focusing, do 15Hz instead of 12Hz
      
      // 60FPS / 15Hz = 4
      // 60FPS / 12Hz = 5
      
    }
    
    // Bomb
    if ((stocks & 0b1000000) == 0b1000000 && (conA & 0b100) == 0b100 && (bombInfo & 0b10) == 0 && ((bombInfo & 0b11111100) >> 2) < 1) // Don't forget about the cooldown
      if ((bombs & 0b11) > 0) {deployBomb(true); bombs--;}
    
    // Ensure P1 is within the bounds of the screen
    if (p1X < 10) p1X = 10;
    if (p1Y < 10) p1Y = 10;
    if (p1X > 385) p1X = 385;
    if (p1Y > 385) p1Y = 385;
    
  }
  
  
  // P2 Controls
  if ((plyManagement & 0b10000) == 0) {
    
    // Wait for Start to be pressed
    if ((conB & 0b1) == 0b1) {
      plyManagement += 0b10000;
      stocks += 24; // 3 * 0b1000 = 24 (for binary reasons)
      refreshing = true;
      
      spawnPlayer(false);
    }
    
  } else {
    
    // P2 option magnitude management
    if ((plyManagement & 0b1000000) == 0) {
      if ((bombInfo & 0b1) == 0b1) {if (p2OMag > 0) {p2OMag--;}} else {p2OMag++;}
      refreshing = true;
      
      if (p2OMag >= 25) plyManagement += 0b1000000;
    }
    
    // Update nextShot this frame if needed
    if (((nextShot & 0b11110000) >> 4) > 0)
      nextShot -= 16;
    
    // Controls
    
    // Go up
    if ((conB & 0b10000000) == 0b10000000) {
      
      p2Y -= (conB & 0b10) == 0b10 ? ((plyManagement & 0b10) == 0b10 ? (frameType ? 2 : 1) : 2) : ((plyManagement & 0b10) == 0b10 ? 3 : (frameType ? 4 : 3));
      if ((plyManagement & 0b1) == 0)
        plyManagement += 0b1;
      refreshing = true;
      
    } else if ((conB & 0b1000000) != 0b1000000 && (plyManagement & 0b1) == 0b1)
      plyManagement -= 0b1;
    
    // Go down
    if ((conB & 0b1000000) == 0b1000000) {
      
      p2Y += (conB & 0b10) == 0b10 ? ((plyManagement & 0b10) == 0b10 ? (frameType ? 2 : 1) : 2) : ((plyManagement & 0b10) == 0b10 ? 3 : (frameType ? 4 : 3));
      if ((plyManagement & 0b1) == 0)
        plyManagement += 0b1;
      refreshing = true;
      
    } else if ((conB & 0b10000000) != 0b10000000 && (plyManagement & 0b1) == 0b1)
      plyManagement -= 0b1;
    
    // Go left
    if ((conB & 0b100000) == 0b100000) {
      
      p2X -= (conB & 0b10) == 0b10 ? ((plyManagement & 0b1) == 0b1 ? (frameType ? 2 : 1) : 2) : ((plyManagement & 0b1) == 0b1 ? 3 : 4);
      if ((plyManagement & 0b10) == 0)
        plyManagement += 0b10;
      refreshing = true;
      
    } else if ((conB & 0b10000) != 0b10000 && (plyManagement & 0b10) == 0b10)
      plyManagement -= 0b10;
    
    // Go right
    if ((conB & 0b10000) == 0b10000) {
      
      p2X += (conB & 0b10) == 0b10 ? ((plyManagement & 0b1) == 0b1 ? (frameType ? 2 : 1) : 2) : ((plyManagement & 0b1) == 0b1 ? 3 : 4);
      if ((plyManagement & 0b10) == 0)
        plyManagement += 0b10;
      refreshing = true;
    
    } else if ((conB & 0b100000) != 0b100000 && (plyManagement & 0b1) == 0b10)
      plyManagement -= 0b10;
    
    // Shoot
    if ((stocks & 0b10000000) == 0b10000000 && (conB & 0b1000) == 0b1000 && ((nextShot & 0b11110000) >> 4) < 1 && p2ShotCount < 21) {
      
      addPlayerShot(p2X, p2Y, (byte) WMSHOT, false);
      addPlayerShot((short) (p2X - 7), (short) (p2Y + 4), (byte) WLSHOT, false);
      addPlayerShot((short) (p2X + 7), (short) (p2Y + 4), (byte) WRSHOT, false);
      
      if ((plyManagement & 0b1000000) == 0b1000000) {
        if ((conB & 0b10) == 0b10) {
          // Focus fire
          addPlayerShot((short) (p2X - 13), (short) (p2Y + 6), (byte) WOMSHOT, false);
          addPlayerShot((short) (p2X + 13), (short) (p2Y + 6), (byte) WOMSHOT, false);
          addPlayerShot((short) (p2X - 26), (short) (p2Y + 12), (byte) WOMSHOT, false);
          addPlayerShot((short) (p2X + 26), (short) (p2Y + 12), (byte) WOMSHOT, false);
        } else {
          // Standard fire
          addPlayerShot((short) (p2X - 13), (short) (p2Y + 6), (byte) WOLSHOT, false);
          addPlayerShot((short) (p2X + 13), (short) (p2Y + 6), (byte) WORSHOT, false);
          addPlayerShot((short) (p2X - 26), (short) (p2Y + 12), (byte) WOLSHOT, false);
          addPlayerShot((short) (p2X + 26), (short) (p2Y + 12), (byte) WORSHOT, false);
        }
      }
      
      nextShot += (conB & 0b10) == 0b10 ? 64 : 96; // If focusing, do 10Hz instead of 15Hz
      
      // (60FPS / 10Hz) * 2 ^ 4 = 64 (for binary reasons)
      // (60FPS / 10Hz) * 2 ^ 4 = 96 (also for binary reasons)
      
    }
    
    // Bomb
    if ((stocks & 0b10000000) == 0b10000000 && (conB & 0b100) == 0b100 && (bombInfo & 0b1) == 0)
      if (((bombs & 0b1100) >> 2) > 0) {deployBomb(false); bombs -= 0b100;}
    
    // Ensure P2 is within the bounds of the screen
    if (p2X < 10) p2X = 10;
    if (p2Y < 10) p2Y = 10;
    if (p2X > 385) p2X = 385;
    if (p2Y > 385) p2Y = 385;
    
  }
  
  
  // Advance the player shots and check for enemy collision
  for (byte i = 0; i < p1ShotY.length; i++) {
    switch (p1ShotType[i]) {
      
      case LSHOT:
      case LOMSHOT:
        p1ShotY[i] -= 25;
        break;
      
      case LOLFSHOT:
        p1ShotY[i] -= 21;
        p1ShotX[i] -= 1;
        break;
      
      case LOLNSHOT:
        p1ShotY[i] -= 23;
        p1ShotX[i] -= frameType ? 1 : 0;
        break;
      
      case LORFSHOT:
        p1ShotY[i] -= 21;
        p1ShotX[i] += 1;
        break;
      
      case LORNSHOT:
        p1ShotY[i] -= 23;
        p1ShotX[i] += frameType ? 1 : 0;
        break;
      
    }
    
    boolean differing = true;
    for (short j = 0; j < p1ShotRemoval.length; j++) {if (p1ShotRemoval[j] == i) {differing = false; break;}}
    
    if (differing && p1ShotY[i] < -32) {differing = false; markPlayerShotForRemoval(i, true);}
    else if (differing) {
      for (short j = 0; j < enemies.length; j++) {
        if (
          (p1ShotX[i] - 1 < enemies[j].getX() + enemies[j].boxWidth / 2 && p1ShotX[i] + 1 > enemies[j].getX() - enemies[j].boxWidth / 2) &&
          (p1ShotY[i] - 1 < enemies[j].getY() + enemies[j].boxHeight / 2 && p1ShotY[i] + 1 > enemies[j].getY() - enemies[j].boxHeight / 2)
        ) {
          switch (p1ShotType[i]) {
            case LSHOT:
              enemies[j].damage((short) 2);
              break;
            
            case LOMSHOT:
            case LOLNSHOT:
            case LOLFSHOT:
            case LORNSHOT:
            case LORFSHOT:
              enemies[j].damage((short) 1);
              break;
            
            default:
              println("Bad shot type when hitting enemy (P1).");
          }
          
          if ((enemies[j].management & 0b100000) == 0) {
            differing = false;
            markPlayerShotForRemoval(i, true);
          }
        }
      }
    }
    
    refreshing = true;
  }
  
  // Remove P1 shots that are marked to do so
  for (short i = 0; i < p1ShotRemoval.length; i++) {
    removePlayerShot(p1ShotRemoval[i], true);
    for (short j = 0; j < p1ShotRemoval.length; j++) {if (p1ShotRemoval[j] > p1ShotRemoval[i]) p1ShotRemoval[j]--;}
  }
  
  p1ShotRemoval = new byte[0];
  
  for (byte i = 0; i < p2ShotY.length; i++) {
    switch (p2ShotType[i]) {
    
      case WMSHOT:
      case WOMSHOT:
        p2ShotY[i] -= 25;
        break;
      
      case WLSHOT:
        p2ShotY[i] -= 22;
        p2ShotX[i] -= frameType ? 1 : 0;
        break;
      
      case WRSHOT:
        p2ShotY[i] -= 22;
        p2ShotX[i] += frameType ? 1 : 0;
        break;
      
      case WOLSHOT:
        p2ShotY[i] -= 20;
        p2ShotX[i] -= frameType ? 2 : 1;
        break;
      
      case WORSHOT:
        p2ShotY[i] -= 20;
        p2ShotX[i] += frameType ? 2 : 1;
        break;
      
    }
    
    boolean differing = true;
    for (short j = 0; j < p2ShotRemoval.length; j++) {if (p2ShotRemoval[j] == i) {differing = false; break;}}
    
    if (differing && p2ShotY[i] < -32) {differing = false; markPlayerShotForRemoval(i, false);}
    else if (differing) {
      for (short j = 0; j < enemies.length; j++) {
        if (
          (p2ShotX[i] - 1 < enemies[j].getX() + enemies[j].boxWidth / 2 && p2ShotX[i] + 1 > enemies[j].getX() - enemies[j].boxWidth / 2) &&
          (p2ShotY[i] - 1 < enemies[j].getY() + enemies[j].boxHeight / 2 && p2ShotY[i] + 1 > enemies[j].getY() - enemies[j].boxHeight / 2)
        ) {
          switch (p2ShotType[i]) {
            case WMSHOT:
            case WLSHOT:
            case WRSHOT:
              enemies[j].damage((short) 2);
              break;
            
            case WOMSHOT:
            case WOLSHOT:
            case WORSHOT:
              enemies[j].damage((short) 1);
              break;
            
            default:
              println("Bad shot type when hitting enemy (P2).");
          }
          
          if ((enemies[j].management & 0b100000) == 0) {
            differing = false;
            markPlayerShotForRemoval(i, false);
          }
        }
      }
    }
    
    refreshing = true;
  }
  
  // Remove P2 shots that are marked to do so
  for (short i = 0; i < p2ShotRemoval.length; i++) {
    removePlayerShot(p2ShotRemoval[i], false);
    for (short j = 0; j < p2ShotRemoval.length; j++) {if (p2ShotRemoval[j] > p2ShotRemoval[i]) p2ShotRemoval[j]--;}
  }
  
  p2ShotRemoval = new byte[0];
  
  
  // Advance enemy bullets (the fun part)
  for (short i = 0; i < bulletX.length; i++) { // Yes, I'm going as far as to say "short" instead of "byte"
    
    if (bulletType[i] == B_BOMB) {
      
      // Enemy bombs
      
      bulletSpd[i]--; // bulletSpd is now lifespan duration
      
      if (bulletSpd[i] <= 0)
        markBulletForRemoval(i);
      
    } else {
      
      // Enemy bullets (everything else)
      
      bulletX[i] += Math.sin(Math.toRadians(bulletDir[i])) * bulletSpd[i]; // Convert degrees to radians on the go
      bulletY[i] += Math.cos(Math.toRadians(bulletDir[i])) * bulletSpd[i];
      
      boolean differing = true; // Are we changing the properties of this bullet?
      for (short j = 0; j < bulletRemoval.length; j++) {if (bulletRemoval[j] == i) {differing = false; break;}}
      
      // Check if we are outside bounds or touching P1 bomb
      if (
        differing &&
        (
          bulletX[i] < -32 || bulletX[i] > 432 || bulletY[i] < -32 || bulletY[i] > 432 ||
          (
            (bombInfo & 0b10) == 0b10 && (bulletX[i] > p1BombX - p1BombSize / 2 && bulletX[i] < p1BombX + p1BombSize / 2) &&
            (bulletY[i] > p1BombY - p1BombSize / 2 && bulletY[i] < p1BombY + p1BombSize / 2)
          )
        )
      ) {markBulletForRemoval(i);}
      
      // Check if we are touching P2 bombs
      if ((bombInfo & 0b1) == 0b1) {
        
        short[] tempX = p2BombX.clone();
        short[] tempY = p2BombY.clone();
        short[] tempS = p2BombSize.clone();
        
        for (short j = 0; j < tempX.length; j++) {
          differing = true;
          for (short k = 0; k < bulletRemoval.length; k++) {if (bulletRemoval[k] == i) {differing = false; break;}}
          
          if (
            differing &&
            (bulletX[i] > tempX[j] - tempS[j] / 2 && bulletX[i] < tempX[j] + tempS[j] / 2) &&
            (bulletY[i] > tempY[j] - tempS[j] / 2 && bulletY[i] < tempY[j] + tempS[j] / 2)
          ) {markBulletForRemoval(i); break;}
        }
          
      }
      
    }
    
    // Check if we are touching either of the players (if they are playing)
    
    // Check for P1
    if (
      (plyManagement & 0b100000) == 0b100000 && // Playing?
      (stocks & 0b1000000) == 0b1000000 && // Existing?
      (p1IFrames < 1) && // Vulnerable?
      (dist(bulletX[i], bulletY[i], p1X, p1Y) <= bulletSize[i]) // Colliding?
    ) {
      stocks = (byte) (stocks & 0b10111111);
      respawnTime += 15;
    }
    
    // Check for P2
    if (
      (plyManagement & 0b10000) == 0b10000 && // Playing?
      (stocks & 0b10000000) == 0b10000000 && // Existing?
      (p2IFrames < 1) && // Vulnerable?
      (dist(bulletX[i], bulletY[i], p2X, p2Y) <= bulletSize[i]) // Colliding?
    ) {
      stocks = (byte) (stocks & 0b1111111);
      respawnTime += 240; // 15 & 0b10000 = 240 (for binary reasons)
    }
    
    refreshing = true;
  }
  
  // Remove bullets that are marked to do so
  for (short i = 0; i < bulletRemoval.length; i++) {
    removeBullet(bulletRemoval[i]);
    for (short j = 0; j < bulletRemoval.length; j++) {if (bulletRemoval[j] > bulletRemoval[i]) bulletRemoval[j]--;}
  }
  
  bulletRemoval = new short[0];
  
  
  // Update bombs if needed
  
  // Update P1 bomb
  if (frameType && (bombInfo & 0b10) == 0b10) {
    if (((bombInfo & 0b11111100) >> 2) > 0) {
      
      if (((bombInfo & 0b11111100) >> 2) < 8) {p1BombSize -= 20;}
      
      bombInfo -= 0b100;
      p1BombY -= 12;
      p1BombX += subFrameType ? 4 : -4;
      
    } else {
      
      bombInfo = (byte) (bombInfo & 0b11111101);
      bombInfo += 0b11111100; // This timer becomes the cooldown
      
    }
    
    for (short i = 0; i < enemies.length; i++) {
      if (
        (p1BombX - p1BombSize / 2 < enemies[i].getX() + enemies[i].boxWidth / 2 && p1BombX + p1BombSize / 2 > enemies[i].getX() - enemies[i].boxWidth / 2) &&
        (p1BombY - p1BombSize / 2 < enemies[i].getY() + enemies[i].boxHeight / 2 && p1BombY + p1BombSize / 2 > enemies[i].getY() - enemies[i].boxHeight / 2)
      ) enemies[i].damage((short) 1);
    }
    
    refreshing = true;
    
  } else if (frameType && (bombInfo & 0b10) == 0 && ((bombInfo & 0b11111100) >> 2) > 0)
    bombInfo -= 0b100;
  
  // Update P2 bombs
  for (byte i = 0; i < p2BombX.length; i++) {
  
    p2BombSize[i] += 4;
    
    if (p2BombSize[i] >= 60) {removeP2Bomb(i--); refreshing = true; continue;}
    
    for (short j = 0; j < enemies.length; j++) {
      if (
        (p2BombX[i] - p2BombSize[i] / 2 < enemies[j].getX() + enemies[j].boxWidth / 2 && p2BombX[i] + p2BombSize[i] / 2 > enemies[j].getX() - enemies[j].boxWidth / 2) &&
        (p2BombY[i] - p2BombSize[i] / 2 < enemies[j].getY() + enemies[j].boxHeight / 2 && p2BombY[i] + p2BombSize[i] / 2 > enemies[j].getY() - enemies[j].boxHeight / 2)
      ) enemies[j].damage((short) 1);
    }
    
    refreshing = true;
    
  }
  
  // Spawn P2 bombs (if necessary)
  if (frameType && subFrameType && ((bombs & 0b11110000) >> 4) > 0) {
    
    addP2Bomb((short) (p2BombOriginX - 15), (short) (p2BombOriginY - 40 * (7 - ((bombs & 0b11110000) >> 4))), (short) 10); // How did we, collectively, let "(short) 10" happen?
    addP2Bomb((short) (p2BombOriginX + 15), (short) (p2BombOriginY - 40 * (7 - ((bombs & 0b11110000) >> 4))), (short) 10);
    addP2Bomb((short) (p2BombOriginX - 23 * (7 - ((bombs & 0b11110000) >> 4))), (short) (p2BombOriginY - 37 * (7 - ((bombs & 0b11110000) >> 4))), (short) (10));
    addP2Bomb((short) (p2BombOriginX + 23 * (7 - ((bombs & 0b11110000) >> 4))), (short) (p2BombOriginY - 37 * (7 - ((bombs & 0b11110000) >> 4))), (short) (10));
    
    bombs -= 0b10000;
    
    refreshing = true;
    
  } else if (frameType && subFrameType && p2BombX.length <= 0) {
    
    bombInfo = (byte) (bombInfo & 0b11111110);
    
  }
  
  // Respawn / tick respawn timers
  if (frameType && (respawnTime & 0b1111) > 0)
    respawnTime--;
  else if (frameType && (stocks & 0b1000000) == 0)
    spawnPlayer(true);
  
  if (((respawnTime & 0b11110000) >> 4) > 0)
    respawnTime -= 16; // 1 * 0b10000 = 16 (for binary reasons)
  else if ((stocks & 0b10000000) == 0)
    spawnPlayer(false);
  
  // Tick invincibility-frame timers
  if (p1IFrames > 0) p1IFrames--;
  if (p2IFrames > 0) p2IFrames--;
  
  
  
  // Other tasks
  
  // if (simulatedFrames == 1) {addEnemy(new S1Tank((short) 200, (short) 75)); refreshing = true;}
  // if (simulatedFrames == 1) {addEnemy(new S2Fortress((short) 200, (short) 0)); refreshing = true;}
  // if (simulatedFrames == 1) {addEnemy(new S3Aircraft((short) 200, (short) 100)); refreshing = true;}
  
  boolean bossAbsent = true;
  
  if (generallySpawningBosses && spawningBoss) {
    
    timeUntilBossSpawn--;
    
    if (timeUntilBossSpawn < 0) {
      spawningBoss = false;
      
      switch (stage) {
        
        case 1:
          centerText = "Stage 1: Tank";
          centerTextX = 100;
          centerTextY = 100;
          addEnemy(new S1Tank((short) 200, (short) 75));
          break;
        
        case 2:
          centerText = "Stage 2: Fortress";
          centerTextX = 82;
          centerTextY = 100;
          addEnemy(new S2Fortress((short) 200, (short) 0));
          break;
        
        case 3:
          centerText = "Stage 3: Aircraft";
          centerTextX = 95;
          centerTextY = 100;
          addEnemy(new S3Aircraft((short) 200, (short) 100));
          break;
        
        case 4:
          centerText = "Complete!";
          centerTextX = 118;
          centerTextY = 100;
          generallySpawningBosses = false;
          break;
        
        default:
          centerText = "Error loading boss #" + stage;
          centerTextX = 75;
          centerTextY = 100;
        
      }
      
      centerTextTimer = 240;
      refreshing = true;
    }
    
  } else if (generallySpawningBosses) {
    
    for (byte i = 0; i < enemies.length; i++) {
      if (
        enemies[i] instanceof S1Tank ||
        enemies[i] instanceof S2Fortress ||
        enemies[i] instanceof S3Aircraft
      ) {bossAbsent = false; break;}
    }
    
    if (bossAbsent) {
      stage++;
      timeUntilBossSpawn = 180;
      spawningBoss = true;
    }
    
  }
  
  if (centerTextTimer > 0) {
    centerTextTimer--;
    if (centerTextTimer == 0)
      refreshing = true;
  }
  
  
  // Check if the player wants to pause
  if (pausePressed && canPause) {
    paused = true;
    canPause = false;
    refreshing = true;
  } else if (!pausePressed && !canPause)
    canPause = true;
  
  
  // Redraw the screen (refer to the "refresh" tab)
  if (refreshing) refresh();
  
  lastProcessTime = System.nanoTime() - timer;
  
  // This should run around 60 FPS
  try {TimeUnit.NANOSECONDS.sleep(16666667 - (lastProcessTime));} catch (InterruptedException e) {} catch (IllegalArgumentException e) {
    try {TimeUnit.NANOSECONDS.sleep(16666667);} catch (InterruptedException ex) {}
  }
}

// If high-scores are added:

/*

  1st     100000 T CAV
  2nd      70000 A RAI
  3rd      50000 3 TOA
  4th      30000 2 PSI
  5th      10000 1 NMK

*/
