// Redraw the screen
void refresh() {
  background(0, 0, 0);
  
  stroke(0, 0, 0);
  strokeWeight(1);
  
  short optionFinalX;
  
  
  /*
    Order of operation:
    
    - P1 bomb
    - P2 bomb
    - P2 shots
    - P2 options
    - P2
    - P1 shots
    - P1 options
    - P1
    
    The further an item is down the list, the higher priority they get when displaying.
  */
  
  
  // Draw P1 bomb
  if ((bombInfo & 0b10) == 0b10) {
    fill(223, 223, 0);
    circle(p1BombX, p1BombY, p1BombSize);
  }
  
  // Draw P2 bomb
  if ((bombInfo & 0b1) == 0b1) {}
  
  
  // Is P2 playing?
  if ((plyManagement & 0b10000) == 0b10000) {
    
    // Draw player 2 shots
    strokeWeight(0);
    for (byte i = 0; i < p2ShotX.length; i++) {
      switch (p2ShotType[i]) {
        
        case WMSHOT:
        case WLSHOT:
        case WRSHOT:
          fill(191, 191, 255);
          // rect(p2ShotX[i] - 3, p2ShotY[i] - 7, 6, 14);
          triangle(p2ShotX[i], p2ShotY[i] - 7, p2ShotX[i] - 3, p2ShotY[i] + 7, p2ShotX[i] + 3, p2ShotY[i] + 7);
          break;
        
        case WOLSHOT:
        case WORSHOT:
        case WOMSHOT:
          fill(127, 127, 191);
          // rect(p2ShotX[i] - 2, p2ShotY[i] - 5, 4, 10);
          triangle(p2ShotX[i], p2ShotY[i] - 6, p2ShotX[i] - 2, p2ShotY[i] + 6, p2ShotX[i] + 2, p2ShotY[i] + 6);
          break;
          
        default:
          println("Bad shot type (P2).");
        
      }
    }
    
    // Draw player 2 options
    strokeWeight(1);
    fill(95, 95, 255);  
    
    optionFinalX = (short) (p2X + ((p1OX - 25) * ((float) p2OMag / 25)));
    triangle(optionFinalX - 3, p2Y + 5, optionFinalX - 7, p2Y + 14, optionFinalX + 2, p2Y + 12);
    
    optionFinalX = (short) (p2X - ((p1OX - 25) * ((float) p2OMag / 25)));
    triangle(optionFinalX + 3, p2Y + 5, optionFinalX - 2, p2Y + 12, optionFinalX + 7, p2Y + 14);
    
    optionFinalX = (short) (p2X + ((p1OX - 15) * ((float) p2OMag / 25)));
    triangle(optionFinalX, p2Y, optionFinalX - 5, p2Y + 10, optionFinalX + 5, p2Y + 10);
    
    optionFinalX = (short) (p2X - ((p1OX - 15) * ((float) p2OMag / 25)));
    triangle(optionFinalX, p2Y, optionFinalX - 5, p2Y + 10, optionFinalX + 5, p2Y + 10);
    
    
    // Draw player 2
    triangle(p2X, p2Y - 12, p2X - 8, p2Y + 12, p2X + 8, p2Y + 12);
    
  }
  
  // Is P1 playing?
  if ((plyManagement & 0b100000) == 0b100000) {
    
    // Draw player 1 shots
    strokeWeight(0);
    for (byte i = 0; i < p1ShotX.length; i++) {
      switch (p1ShotType[i]) {
        
        case LSHOT:
          fill(255, 191, 191);
          triangle(p1ShotX[i], p1ShotY[i] - 7, p1ShotX[i] - 3, p1ShotY[i] + 7, p1ShotX[i] + 3, p1ShotY[i] + 7);
          break;
        
        case LOLNSHOT:
        case LOLFSHOT:
        case LORNSHOT:
        case LORFSHOT:
        case LOMSHOT:
          fill(191, 127, 127);
          triangle(p1ShotX[i], p1ShotY[i] - 6, p1ShotX[i] - 2, p1ShotY[i] + 6, p1ShotX[i] + 2, p1ShotY[i] + 6);
          break;
          
        default:
          println("Bad shot type (P1).");
        
      }
    }
    
    // Draw player 1 options
    strokeWeight(1);
    fill(255, 63, 63);
    
    optionFinalX = (short) (p1X + ((p1OX - 16) * ((float) p1OMag / 25)));
    triangle(optionFinalX - 2, p1Y + 5, optionFinalX - 5, p1Y + 13, optionFinalX + 3, p1Y + 13);
    
    optionFinalX = (short) (p1X - ((p1OX - 16) * ((float) p1OMag / 25)));
    triangle(optionFinalX + 2, p1Y + 5, optionFinalX - 3, p1Y + 13, optionFinalX + 5, p1Y + 13);
    
    optionFinalX = (short) (p1X + ((p1OX - 12) * ((float) p1OMag / 25)));
    triangle(optionFinalX, p1Y - 8, optionFinalX - 5, p1Y + 2, optionFinalX + 5, p1Y + 2);
    
    optionFinalX = (short) (p1X - ((p1OX - 12) * ((float) p1OMag / 25)));
    triangle(optionFinalX, p1Y - 8, optionFinalX - 5, p1Y + 2, optionFinalX + 5, p1Y + 2);
    
    
    // Draw player 1
    triangle(p1X, p1Y - 12, p1X - 8, p1Y + 12, p1X + 8, p1Y + 12);
  
  }
}
