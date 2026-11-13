/*
  Controls:
  
  P1:
  
  Move: WASD
  Shoot: 4
  Bomb: 5
  Focus: 6
  Start: 1
  
  
  P2:
  
  Move: Arrow keys
  Shoot: P
  Bomb: - or _
  Focus: = or +
  
  
  I apologize if the controls are cramped; they are positioned for the very rare case
  two people play on the same keyboard.

*/

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
        conB = (byte) (conB | 0b10000000);
        break;
      
      // P2 Down
      case DOWN:
        conB = (byte) (conB | 0b1000000);
        break;
      
      // P2 Left
      case LEFT:
        conB = (byte) (conB | 0b100000);
        break;
      
      // P2 Right
      case RIGHT:
        conB = (byte) (conB | 0b10000);
        break;
      
    }
  } else {
    switch (String.valueOf(key).toLowerCase().charAt(0)) {
      
      // P1 Up
      case 'w':
        conA = (byte) (conA | 0b10000000);
        break;
      
      // P1 Down
      case 's':
        conA = (byte) (conA | 0b1000000);
        break;
      
      // P1 Left
      case 'a':
        conA = (byte) (conA | 0b100000);
        break;
      
      // P1 Right
      case 'd':
        conA = (byte) (conA | 0b10000);
        break;
      
      // P1 Shoot
      case '4':
        conA = (byte) (conA | 0b1000);
        break;
      
      // P1 Bomb
      case '5':
        conA = (byte) (conA | 0b100);
        break;
      
      // P1 Focus
      case '6':
        conA = (byte) (conA | 0b10);
        break;
      
      // P1 Start
      case '1':
        conA = (byte) (conA | 0b1);
        break;
      
      // P2 Shoot
      case 'p':
        conB = (byte) (conB | 0b1000);
        break;
      
      // P2 Bomb
      case '-':
      case '_':
        conB = (byte) (conB | 0b100);
        break;
      
      // P2 Focus
      case '=':
      case '+':
        conB = (byte) (conB | 0b10);
        break;
      
      // P2 Start
      case '0':
        conB = (byte) (conB | 0b1);
        break;
      
    }
  }
}


void keyReleased() {
  if (key == CODED) {
    switch (keyCode) {
      
      // P2 Up
      case UP:
        conB = (byte) (conB & 0b1111111);
        break;
      
      // P2 Down
      case DOWN:
        conB = (byte) (conB & 0b10111111);
        break;
      
      // P2 Left
      case LEFT:
        conB = (byte) (conB & 0b11011111);
        break;
      
      // P2 Right
      case RIGHT:
        conB = (byte) (conB & 0b11101111);
        break;
      
    }
  } else {
    switch (String.valueOf(key).toLowerCase().charAt(0)) {
      
      // P1 Up
      case 'w':
        conA = (byte) (conA & 0b1111111);
        break;
      
      // P1 Down
      case 's':
        conA = (byte) (conA & 0b10111111);
        break;
      
      // P1 Left
      case 'a':
        conA = (byte) (conA & 0b11011111);
        break;
      
      // P1 Right
      case 'd':
        conA = (byte) (conA & 0b11101111);
        break;
      
      // P1 Shoot
      case '4':
        conA = (byte) (conA & 0b11110111);
        break;
      
      // P1 Bomb
      case '5':
        conA = (byte) (conA & 0b11111011);
        break;
      
      // P1 Focus
      case '6':
        conA = (byte) (conA & 0b11111101);
        break;
      
      // P1 Start
      case '1':
        conA = (byte) (conA & 0b11111110);
        break;
      
      // P2 Shoot
      case 'p':
        conB = (byte) (conB & 0b11110111);
        break;
      
      // P2 Bomb
      case '-':
      case '_':
        conB = (byte) (conB & 0b11111011);
        break;
      
      // P2 Focus
      case '=':
      case '+':
        conB = (byte) (conB & 0b11111101);
        break;
      
      // P2 Start
      case '0':
        conB = (byte) (conB & 0b11111110);
        break;
      
    }
  }
}
