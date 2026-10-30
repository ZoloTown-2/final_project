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
    
    bombInfo += 0b1;
    plyManagement += 0b1000000;
    
  }
}
