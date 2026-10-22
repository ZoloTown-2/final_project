// Redraw the screen
void refresh() {
  background(0, 0, 0);
  
  stroke(0, 0, 0);
  strokeWeight(1);
  
  short optionFinalX;
  
  
  // Is P2 playing?
  if ((plyManagement & 0b100000) == 0b100000) {
    
    // Draw player 2 options
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
  if ((plyManagement & 0b1000000) == 0b1000000) {
    
    // Draw player 1 options
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