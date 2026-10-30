// Input variables
/*
  01234567
  
  0: Up
  1: Down
  2: Left
  3: Right
  4: Shoot
  5: Bomb
  6: Focus
  7: Start
*/
byte conA = 0, conB = 0;


void keyPressed() {
  if (key == CODED) {
    switch (keyCode) {
      
      // P2 Up
      case UP:
        if ((conB & 0b10000000) == 0b10000000) return;
        conB += 0b10000000;
        break;
      
      // P2 Down
      case DOWN:
        if ((conB & 0b1000000) == 0b1000000) return;
        conB += 0b1000000;
        break;
      
      // P2 Left
      case LEFT:
        if ((conB & 0b100000) == 0b100000) return;
        conB += 0b100000;
        break;
      
      // P2 Right
      case RIGHT:
        if ((conB & 0b10000) == 0b10000) return;
        conB += 0b10000;
        break;
      
    }
  } else {
    switch (String.valueOf(key).toLowerCase().charAt(0)) {
      
      // P1 Up
      case 'w':
        if ((conA & 0b10000000) == 0b10000000) return;
        conA += 0b10000000;
        break;
      
      // P1 Down
      case 's':
        if ((conA & 0b1000000) == 0b1000000) return;
        conA += 0b1000000;
        break;
      
      // P1 Left
      case 'a':
        if ((conA & 0b100000) == 0b100000) return;
        conA += 0b100000;
        break;
      
      // P1 Right
      case 'd':
        if ((conA & 0b10000) == 0b10000) return;
        conA += 0b10000;
        break;
      
      // P1 Shoot
      case '4':
        if ((conA & 0b1000) == 0b1000) return;
        conA += 0b1000;
        break;
      
      // P1 Bomb
      case '5':
        if ((conA & 0b100) == 0b100) return;
        conA += 0b100;
        break;
      
      // P1 Focus
      case '6':
        if ((conA & 0b10) == 0b10) return;
        conA += 0b10;
        break;
      
      // P1 Start
      case '1':
        if ((conA & 0b1) == 0b1) return;
        conA += 0b1;
        break;
      
      // P2 Shoot
      case 'o':
        if ((conB & 0b1000) == 0b1000) return;
        conB += 0b1000;
        break;
      
      // P2 Bomb
      case 'l':
        if ((conB & 0b100) == 0b100) return;
        conB += 0b100;
        break;
      
      // P2 Focus
      case 'p':
        if ((conB & 0b10) == 0b10) return;
        conB += 0b10;
        break;
      
      case '0':
        if ((conB & 0b1) == 0b1) return;
        conB += 0b1;
        break;
      
    }
  }
}


void keyReleased() {
  if (key == CODED) {
    switch (keyCode) {
      
      // P2 Up
      case UP:
        if ((conB & 0b10000000) == 0) return;
        conB -= 0b10000000;
        break;
      
      // P2 Down
      case DOWN:
        if ((conB & 0b1000000) == 0) return;
        conB -= 0b1000000;
        break;
      
      // P2 Left
      case LEFT:
        if ((conB & 0b100000) == 0) return;
        conB -= 0b100000;
        break;
      
      // P2 Right
      case RIGHT:
        if ((conB & 0b10000) == 0) return;
        conB -= 0b10000;
        break;
      
    }
  } else {
    switch (String.valueOf(key).toLowerCase().charAt(0)) {
      
      // P1 Up
      case 'w':
        if ((conA & 0b10000000) == 0) return;
        conA -= 0b10000000;
        break;
      
      // P1 Down
      case 's':
        if ((conA & 0b1000000) == 0) return;
        conA -= 0b1000000;
        break;
      
      // P1 Left
      case 'a':
        if ((conA & 0b100000) == 0) return;
        conA -= 0b100000;
        break;
      
      // P1 Right
      case 'd':
        if ((conA & 0b10000) == 0) return;
        conA -= 0b10000;
        break;
      
      // P1 Shoot
      case '4':
        if ((conA & 0b1000) == 0) return;
        conA -= 0b1000;
        break;
      
      // P1 Bomb
      case '5':
        if ((conA & 0b100) == 0) return;
        conA -= 0b100;
        break;
      
      // P1 Focus
      case '6':
        if ((conA & 0b10) == 0) return;
        conA -= 0b10;
        break;
      
      // P1 Start
      case '1':
        if ((conA & 0b1) == 0) return;
        conA -= 0b1;
        break;
      
      // P2 Shoot
      case 'o':
        if ((conB & 0b1000) == 0) return;
        conB -= 0b1000;
        break;
      
      // P2 Bomb
      case 'l':
        if ((conB & 0b100) == 0) return;
        conB -= 0b100;
        break;
      
      // P2 Focus
      case 'p':
        if ((conB & 0b10) == 0) return;
        conB -= 0b10;
        break;
      
      case '0':
        if ((conB & 0b1) == 0) return;
        conB -= 0b1;
        break;
      
    }
  }
}
