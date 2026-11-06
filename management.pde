void addPlayerShot(short x, short y, byte type, boolean player) {
  if (player) {
    
    // Player 1
    
    p1ShotCount++;
    
    short[] tempX = new short[p1ShotX.length + 1];
    short[] tempY = new short[p1ShotY.length + 1];
    byte[] tempT = new byte[p1ShotType.length + 1];
    
    for (byte i = 0; i < p1ShotX.length; i++) {
      tempX[i] = p1ShotX[i];
      tempY[i] = p1ShotY[i];
      tempT[i] = p1ShotType[i];
    }
    
    tempX[tempX.length - 1] = x;
    tempY[tempY.length - 1] = y;
    tempT[tempT.length - 1] = type;
    
    p1ShotX = tempX;
    p1ShotY = tempY;
    p1ShotType = tempT;
    
  } else {
    
    // Player 2
    
    p2ShotCount++;
    
    short[] tempX = new short[p2ShotX.length + 1];
    short[] tempY = new short[p2ShotY.length + 1];
    byte[] tempT = new byte[p2ShotType.length + 1];
    
    for (byte i = 0; i < p2ShotX.length; i++) {
      tempX[i] = p2ShotX[i];
      tempY[i] = p2ShotY[i];
      tempT[i] = p2ShotType[i];
    }
    
    tempX[tempX.length - 1] = x;
    tempY[tempY.length - 1] = y;
    tempT[tempT.length - 1] = type;
    
    p2ShotX = tempX;
    p2ShotY = tempY;
    p2ShotType = tempT;
    
  }
}

void removePlayerShot(byte index, boolean player) {
  if (player) {
    
    // Player 1
    
    p1ShotCount--;
    
    short[] tempX = new short[p1ShotX.length - 1];
    short[] tempY = new short[p1ShotY.length - 1];
    byte[] tempT = new byte[p1ShotType.length - 1];
    boolean skipped = false;
    
    for (byte i = 0; i < p1ShotX.length; i++) {
      
      if (i == index) {skipped = true; continue;}
      
      tempX[skipped ? i - 1 : i] = p1ShotX[i];
      tempY[skipped ? i - 1 : i] = p1ShotY[i];
      tempT[skipped ? i - 1 : i] = p1ShotType[i];
      
    }
    
    p1ShotX = tempX;
    p1ShotY = tempY;
    p1ShotType = tempT;
    
  } else {
    
    // Player 2
    
    p2ShotCount--;
    
    short[] tempX = new short[p2ShotX.length - 1];
    short[] tempY = new short[p2ShotY.length - 1];
    byte[] tempT = new byte[p2ShotType.length - 1];
    boolean skipped = false;
    
    for (byte i = 0; i < p2ShotX.length; i++) {
      
      if (i == index) {skipped = true; continue;}
      
      tempX[skipped ? i - 1 : i] = p2ShotX[i];
      tempY[skipped ? i - 1 : i] = p2ShotY[i];
      tempT[skipped ? i - 1 : i] = p2ShotType[i];
      
    }
    
    p2ShotX = tempX;
    p2ShotY = tempY;
    p2ShotType = tempT;
    
  }
}

void addBullet(short x, short y, short dir, byte speed) {
  
  bulletCount++;
  
  short[] tempX = new short[bulletX.length + 1];
  short[] tempY = new short[bulletY.length + 1];
  short[] tempD = new short[bulletDir.length + 1];
  byte[] tempS = new byte[bulletSpd.length + 1];
  
  for (short i = 0; i < bulletX.length; i++) {
    tempX[i] = bulletX[i];
    tempY[i] = bulletY[i];
    tempD[i] = bulletDir[i];
    tempS[i] = bulletSpd[i];
  }
  
  tempX[tempX.length - 1] = x;
  tempY[tempY.length - 1] = y;
  tempD[tempD.length - 1] = dir;
  tempS[tempS.length - 1] = speed;
  
  bulletX = tempX;
  bulletY = tempY;
  bulletDir = tempD;
  bulletSpd = tempS;
  
}

void removeBullet(short index) {
  
  bulletCount--;
  
  short[] tempX = new short[bulletX.length - 1];
  short[] tempY = new short[bulletY.length - 1];
  short[] tempD = new short[bulletDir.length - 1];
  byte[] tempS = new byte[bulletSpd.length - 1];
  boolean skipped = false;
  
  for (short i = 0; i < bulletX.length; i++) {
    
    if (i == index) {skipped = true; continue;}
    
    tempX[skipped ? i - 1 : i] = bulletX[i];
    tempY[skipped ? i - 1 : i] = bulletY[i];
    tempD[skipped ? i - 1 : i] = bulletDir[i];
    tempS[skipped ? i - 1 : i] = bulletSpd[i];
    
  }
  
  bulletX = tempX;
  bulletY = tempY;
  bulletDir = tempD;
  bulletSpd = tempS;
  
}

void addP2Bomb(short x, short y, short size) {
  
  short[] tempX = new short[p2BombX.length + 1];
  short[] tempY = new short[p2BombY.length + 1];
  short[] tempS = new short[p2BombSize.length + 1];
  
  for (byte i = 0; i < p2BombX.length; i++) {
    tempX[i] = p2BombX[i];
    tempY[i] = p2BombY[i];
    tempS[i] = p2BombSize[i];
  }
  
  tempX[tempX.length - 1] = x;
  tempY[tempY.length - 1] = y;
  tempS[tempS.length - 1] = size;
  
  p2BombX = tempX;
  p2BombY = tempY;
  p2BombSize = tempS;
  
}

void removeP2Bomb(byte index) {
  
  short[] tempX = new short[p2BombX.length - 1];
  short[] tempY = new short[p2BombY.length - 1];
  short[] tempS = new short[p2BombSize.length - 1];
  boolean skipped = false;
  
  for (byte i = 0; i < p2BombX.length; i++) {
    
    if (i == index) {skipped = true; continue;}
    
    tempX[skipped ? i - 1 : i] = p2BombX[i];
    tempY[skipped ? i - 1 : i] = p2BombY[i];
    tempS[skipped ? i - 1 : i] = p2BombSize[i];
    
  }
  
  p2BombX = tempX;
  p2BombY = tempY;
  p2BombSize = tempS;

}

void deployBomb(boolean player) {
  if (player) {
    
    // Player 1 (Raiden)
    
    if ((bombInfo & 0b10) == 0b10 || ((bombInfo & 0b10) == 0 && ((bombInfo & 0b11111100) >> 2) > 0)) return;
    
    p1BombSize = 180;
    p1BombX = (short) (p1X + (subFrameType ? 4 : -4)); p1BombY = (short) (p1Y + 8);
    bombInfo += 0b1111110; // 0b10 + 0b11111100
    plyManagement += 0b10000000;
    
  } else {
    
    // Player 2 (Ibara P1-A)
    
    if ((bombInfo & 0b1) == 0b1) return;
    
    p2BombOriginX = p2X;
    p2BombOriginY = p2Y;
    
    bombInfo += 0b1;
    bombs += 0b1110000;
    plyManagement -= 0b1000000; // I don't know why this works
    
  }
}

void markBulletForRemoval(short index) {

  short[] temp = new short[bulletRemoval.length + 1];
  
  for (short i = 0; i < bulletRemoval.length; i++) {
    temp[i] = bulletRemoval[i];
  }
  
  temp[temp.length - 1] = index;
  
  bulletRemoval = temp;

}


void spawnPlayer(boolean player) {
  if (player) {
    
    // P1
    if ((stocks & 0b1000000) == 0) {
      if ((stocks & 0b111) > 0) {
        p1X = 100;
        p1Y = 350;
        stocks -= 1;
        stocks = (byte) (stocks | 0b1000000);
        p1IFrames = 127;
      } else if ((plyManagement & 0b100000) == 0b100000) {
        println("P1 Game over");
        plyManagement = (byte) (plyManagement & 0b11011111);
      }
    }
    
  } else {
    
    // P2
    if ((stocks & 0b10000000) == 0) {
      if (((stocks & 0b111000) >> 3) > 0) {
        p2X = 300;
        p2Y = 350;
        stocks -= 0b1000;
        stocks = (byte) (stocks | 0b10000000);
        p2IFrames = 127;
      } else if ((plyManagement & 0b10000) == 0b10000) {
        println("P2 Game over");
        plyManagement = (byte) (plyManagement & 0b11101111);
      }
    }
    
  }
}
