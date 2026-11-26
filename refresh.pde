// Redraw the title screen
void refreshTitle() {
  
  textFont(bigText);
  text("Final Project", 50, 100);
  
  textFont(smallText);
  text("Location Test", 50, 300);
  text("ESD 11/25/2026", 50, 320);
  
  for (byte i = 0; i < menuItems.length; i++) {
    text(menuItems[i], 75, 150 + i * 25);
  }
  
  circle(50, 150 + menuItem * 20, 10);
  
}

// Redraw the screen
void refresh() {
  background(0, 0, 0);
  
  stroke(0, 0, 0);
  strokeWeight(1);
  
  textFont(smallText);
  
  if (inTitle) {refreshTitle(); return;}
  
  short optionFinalX;
  
  
  /*
    Order of operation:
    
    - Enemies (oldest to newest)
    - P1 bomb
    - P2 bomb
    - P2 shots
    - P2 options
    - P2
    - P1 shots
    - P1 options
    - P1
    - Enemy bullets
    - P1 bomb count
    - P2 bomb count
    - "[P1] Press 1 to start"
    - "[P2] Press 0 to start"
    - Center text
    - Last process time (optional)
    - Pause text
    
    The further an item is down the list, the higher priority they get when displaying.
  */
  
  // Draw enemies
  for (short i = 0; i < enemies.length; i++) {
    enemies[i].paint();
  }
  
  
  // Draw P1 bomb
  if ((bombInfo & 0b10) == 0b10) {
    fill(223, 191, 0);
    circle(p1BombX, p1BombY, p1BombSize);
  }
  
  // Draw P2 bomb
  if ((bombInfo & 0b1) == 0b1) {
    fill(223, 191, 0);
    for (byte i = 0; i < p2BombX.length; i++) {
      circle(p2BombX[i], p2BombY[i], p2BombSize[i]);
    }
  }
  
  
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
    
    if ((stocks & 0b10000000) == 0b10000000) {
      
      // Draw player 2 options
      // Apply translucence if invulnerable
      if (p2IFrames > 0) {fill(95, 95, 255, 127); stroke(0, 0, 0, 127);} else {fill(95, 95, 255); stroke(0, 0, 0);}
      strokeWeight(1);
      
      optionFinalX = (short) (p2X + ((p1OX - 25) * ((float) p2OMag / 25)));
      triangle(optionFinalX - 3, p2Y + 5, optionFinalX - 7, p2Y + 14, optionFinalX + 2, p2Y + 12);
      
      optionFinalX = (short) (p2X - ((p1OX - 25) * ((float) p2OMag / 25)));
      triangle(optionFinalX + 3, p2Y + 5, optionFinalX - 2, p2Y + 12, optionFinalX + 7, p2Y + 14);
      
      optionFinalX = (short) (p2X + ((p1OX - 15) * ((float) p2OMag / 25)));
      triangle(optionFinalX, p2Y, optionFinalX - 5, p2Y + 10, optionFinalX + 5, p2Y + 10);
      
      optionFinalX = (short) (p2X - ((p1OX - 15) * ((float) p2OMag / 25)));
      triangle(optionFinalX, p2Y, optionFinalX - 5, p2Y + 10, optionFinalX + 5, p2Y + 10);
      
      // Draw player 2
      // triangle(p2X, p2Y - 12, p2X - 8, p2Y + 12, p2X + 8, p2Y + 12);
      beginShape();
      vertex(p2X, p2Y - 10);
      vertex(p2X - 9, p2Y + 10);
      vertex(p2X, p2Y + 7);
      vertex(p2X + 9, p2Y + 10);
      endShape(CLOSE);
      
    }
    
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
    
    // Does P1 exist?
    if ((stocks & 0b1000000) == 0b1000000) {
      
      // Draw player 1 options
      // Apply translucence if invulnerable
      if (p1IFrames > 0) {fill(255, 63, 63, 127); stroke(0, 0, 0, 127);} else {fill(255, 63, 63); stroke(0, 0, 0);}
      strokeWeight(1);
      
      optionFinalX = (short) (p1X + ((p1OX - 16) * ((float) p1OMag / 25)));
      triangle(optionFinalX - 2, p1Y + 5, optionFinalX - 5, p1Y + 13, optionFinalX + 3, p1Y + 13);
      
      optionFinalX = (short) (p1X - ((p1OX - 16) * ((float) p1OMag / 25)));
      triangle(optionFinalX + 2, p1Y + 5, optionFinalX - 3, p1Y + 13, optionFinalX + 5, p1Y + 13);
      
      optionFinalX = (short) (p1X + ((p1OX - 12) * ((float) p1OMag / 25)));
      triangle(optionFinalX, p1Y - 8, optionFinalX - 5, p1Y + 2, optionFinalX + 5, p1Y + 2);
      
      optionFinalX = (short) (p1X - ((p1OX - 12) * ((float) p1OMag / 25)));
      triangle(optionFinalX, p1Y - 8, optionFinalX - 5, p1Y + 2, optionFinalX + 5, p1Y + 2);
      
      
      // Draw player 1
      // triangle(p1X, p1Y - 12, p1X - 8, p1Y + 12, p1X + 8, p1Y + 12);
      beginShape();
      vertex(p1X, p1Y - 12);
      vertex(p1X - 8, p1Y + 12);
      vertex(p1X, p1Y + 6);
      vertex(p1X + 8, p1Y + 12);
      endShape(CLOSE);
      
    }
  
  }
  
  // Draw enemy bullets
  stroke(0, 0, 0);
  strokeWeight(1);
  for (short i = 0; i < bulletX.length; i++) {
    
    // I separated the colouring and the drawing so I didn't have to repeat instructions many times.
    // The bomb is skipped in colouring as it changes colour as it is being drawn, and becaues there is nothing like it so its instructions won't/shouldn't be copied.
    
    switch (bulletType[i]) {
      
      case B_ORANGEBALL:
      case B_ORANGESPIKE:
        fill(255, 127, 0);
        break;
      
      case B_PINKBALL:
      case B_PINKSPIKE:
        fill(255, 127, 223);
        break;
      
      case B_BLUEBALL:
      case B_BLUESPIKE:
        fill(127, 127, 255);
        break;
      
      case B_YELLOWLARGE:
        fill(195, 195, 0);
        break;
      
      case B_BOMB:
        break;
      
      default:
        println("Bad bullet type. (index #" + i + ") [Colour section]");
      
    }
    
    switch (bulletType[i]) {
      
      case B_ORANGEBALL:
        circle(bulletX[i], bulletY[i], 10);
        break;
      
      case B_PINKBALL:
        circle(bulletX[i], bulletY[i], 10);
        break;
      
      case B_BLUEBALL:
        circle(bulletX[i], bulletY[i], 10);
        break;
      
      case B_ORANGESPIKE:
      case B_PINKSPIKE:
      case B_BLUESPIKE:
        pushMatrix();
        translate(bulletX[i], bulletY[i]);
        rotate((float) Math.toRadians(180 - bulletDir[i]));
        triangle(0, -8, -4, 8, 4, 8);
        popMatrix();
        break;
      
      case B_YELLOWLARGE:
        pushMatrix();
        translate(bulletX[i], bulletY[i]);
        rotate((float) Math.toRadians(180 - bulletDir[i]));
        triangle(0, -20, -10, 20, 10, 20);
        popMatrix();
        break;
      
      case B_BOMB:
        fill(255, 0, 0);
        circle(bulletX[i], bulletY[i], subFrameType ? 45 : 60);
        fill(255, 127, 0);
        circle(bulletX[i], bulletY[i], subFrameType ? 30 : 40);
        fill(255, 255, 0);
        circle(bulletX[i], bulletY[i], subFrameType ? 15 : 20);
        break;
      
      default:
        println("Bad bullet type. (index #" + i + ") [Shape section]");
      
    }
    
  }
  
  // Is P1 playing? (for HUD)
  if ((plyManagement & 0b100000) == 0b100000) {
    strokeWeight(0);
    fill(223, 191, 0);
    for (byte i = 0; i < (bombs & 0b11); i++) {
      
      circle(i * 20 + 12, (p1X < (25 * (bombs & 0b11)) && p1Y > 350) || (p2X < (25 * (bombs & 0b11)) && p2Y > 350) ? 50 : 385, 15);
      
    }
    
    fill(255, 63, 63);
    for (byte i = 0; i < (stocks & 0b111); i++) {
      
      beginShape();
      vertex(i * 10 + 8, 24);
      vertex(i * 10 + 4, 36);
      vertex(i * 10 + 8, 32);
      vertex(i * 10 + 12, 36);
      endShape(CLOSE);
      
    }
  } else {
    fill(0, 255, 0);
    text("[P1] Press 1 to join", 3, 15);
  }
  
  // Is P2 playing? (for HUD)
  if ((plyManagement & 0b10000) == 0b10000) {
    strokeWeight(0);
    fill(223, 191, 0);
    for (byte i = 0; i < ((bombs & 0b1100) >> 2); i++) {
      
      circle(400 + (i * -20 - 12), (p1X > 400 - (25 * ((bombs & 0b1100) >> 2)) && p1Y > 350) || (p2X > 400 - (25 * ((bombs & 0b1100) >> 2)) && p2Y > 350) ? 50 : 385, 15);
      
    }
    
    fill(95, 95, 255);
    for (byte i = 0; i < ((stocks & 0b111000) >> 3); i++) {
      
      beginShape();
      vertex(400 + (i * -10) - 8, 26);
      vertex(400 + (i * -10) - 3, 36);
      vertex(400 + (i * -10) - 8, 34);
      vertex(400 + (i * -10) - 13, 36);
      endShape(CLOSE);
      
    }
  } else {
    fill(0, 255, 0);
    text("[P2] Press 0 to join", 295, 15);
  }
  
  if (centerTextTimer > 0) {
    fill(255, 255, 255);
    textFont(bigText);
    text(centerText, centerTextX, centerTextY);
    textFont(smallText);
  }
  
  // Last process time
  fill(255, 255, 255);
  text(Math.round(lastProcessTime / 100), 0, 50);
  
  // Pause text
  if (paused)
    text("PAUSE", 0, 70);
}
