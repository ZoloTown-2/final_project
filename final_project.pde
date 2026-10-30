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

// It'd be really neat if final/const variables were just compiled as literals instead of stored in memory
// They don't really need to be in memory if you think about it

// Player variables
short p1X = 100, p1Y = 350, p2X = 300, p2Y = 350; // P1/2 positions

short p1BombX, p1BombY, p1BombSize;

byte p1OX = 0, p1OY = 0, p2OX = 0, p2OY = 0; // P1/2 option offsets
byte p1OMag = 0, p2OMag = 0; // P1/2 option distance from player when they respawn

byte p1IFrames = 0, p2IFrames = 0;

byte p1ShotCount = 0, p2ShotCount = 0;


/*
  01234567
  
  0-3: Unused
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


// Timer variables
long timer = 0;
boolean frameType = false; // For 30 FPS operations
boolean subFrameType = false;


// Misc variables
boolean refreshing = false;


// Player arrays
short[] p1ShotX = new short[0];
short[] p1ShotY = new short[0];

short[] p2ShotX = new short[0];
short[] p2ShotY = new short[0];

short[] p2BombX = new short[0];
short[] p2BombY = new short[0];

byte[] p1ShotType = new byte[0];
byte[] p2ShotType = new byte[0];


void setup() {
  size(400, 400);
  //noSmooth();
  
  refresh();
}


void draw() {
  timer = System.nanoTime();
  
  frameType = !frameType;
  if (frameType) {subFrameType = !subFrameType;}
  
  refreshing = false;
  
  // P1 Controls
  if ((plyManagement & 0b100000) == 0) {
    
    // Wait for Start to be pressed
    if ((conA & 0b1) == 0b1) {
      plyManagement += 0b100000;
      bombs += 2;
      refreshing = true;
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
    if ((conA & 0b1000) == 0b1000 && (nextShot & 0b1111) < 1 && p1ShotCount < 21) {
      
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
    if ((conA & 0b100) == 0b100 && (bombInfo & 0b10) == 0)
      if (bombs > 0) {deployBomb(true); bombs--;}
    
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
      bombs += 8; // 2 * 0b100 = 8 (for binary reasons)
      refreshing = true;
    }
    
  } else {
    
    // P2 option magnitude management
    if ((plyManagement & 0b1000000) == 0) {
      p2OMag++;
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
    if ((conB & 0b1000) == 0b1000 && ((nextShot & 0b11110000) >> 4) < 1 && p2ShotCount < 21) {
      
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
    
    // Ensure P2 is within the bounds of the screen
    if (p2X < 10) p2X = 10;
    if (p2Y < 10) p2Y = 10;
    if (p2X > 385) p2X = 385;
    if (p2Y > 385) p2Y = 385;
    
  }
  
  
  // Advance the player shots
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
    
    if (p1ShotY[i] < -32) {removePlayerShot(i, true); i--;} // We must go back one since removePlayerShot() removes an item
    refreshing = true;
  }
  
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
    
    if (p2ShotY[i] < -32) {removePlayerShot(i, false); i--;} // Same goes for here; we must go back
    refreshing = true;
  }
  
  
  // Update bombs if needed
  
  // Update P1 bomb
  if (frameType && (bombInfo & 0b10) == 0b10) {
    if (((bombInfo & 0b11111100) >> 2) > 0) {
      if (((bombInfo & 0b11111100) >> 2) < 8) {p1BombSize -= 20;}
      bombInfo -= 0b100;
      p1BombY -= 6;
      p1BombX += subFrameType ? 4 : -4;
      refreshing = true;
    } else {
      bombInfo -= 0b10;
      bombInfo += 0b11111100; // This timer becomes the cooldown
      refreshing = true;
    }
  } else if (frameType && (bombInfo & 0b10) == 0 && ((bombInfo & 0b11111100) >> 2) > 0)
    bombInfo -= 0b100;
  
  // Update P2 bomb
  
  
  // Redraw the screen (refer to the "refresh" tab)
  if (refreshing) refresh();
  
  
  
  // This should run around 60 FPS
  try {TimeUnit.NANOSECONDS.sleep(System.nanoTime() - timer);} catch (InterruptedException e) {} catch (IllegalArgumentException e) {
    try {Thread.sleep(17);} catch (InterruptedException ex) {}
  }
}
