// Enemy flash type variables
final byte FLASH_NONE = 0; // Normal enemy image
final byte FLASH_TICK = 1; // Enemy being damaged (white tint)
final byte FLASH_LOW = 2; // Enemy at low health (red tint)
final byte FLASH_INVULN = 3; // Enemy that is invulnerable (blue tint)

// The rest
abstract class EnemyComp {
  
  EnemyComp parent;
  
  short x, y;
  short boxWidth, boxHeight; // Since "width" and "height" are taken by Processing (I'm sure it would still work but it just looks worrying in the editor)
  
  short health;
  short maxHealth;
  
  // byte flashType = FLASH_NONE; // What tint to apply to this enemy
  
  /*
    01234567
    
    0-2: Unused
    3: Airborne? (will the player get hit by this enemy if they run into them?)
    4: Vulnerable?
    5: Disposable? (are we removing this enemy next frame?)
    6-7: Flash/tint type
  */
  byte management;
  
  
  void damage(short amount) {
    if (((this.management & 0b1000) >> 3) == 1) return;
    
    this.health -= amount;
    
    if (this.health <= 0) {this.management = (byte) (this.management | 0b100);}
    
    this.management -= this.management & 0b11; // Reset the flash value before we modify it
    this.management = (byte) (this.management | FLASH_TICK);
    
    refreshing = true;
  }
  
  void resetTint() {
    byte oldFT = (byte) (this.management & 0b11);
    this.management -= this.management & 0b11;
    
    if (
      (frameType && this.health < this.maxHealth / 12) || // Very very low health, flash very quickly
      (frameType && subFrameType && this.health < this.maxHealth / 6) || // Very low health, flash quickly
      (frameType && subFrameType && subSubFrameType && this.health < this.maxHealth / 3) // Low health, flash moderately
    )
      this.management = (byte) (this.management | FLASH_LOW);
    else if ((this.management& 0b1000) == 1)
      this.management = (byte) (this.management | FLASH_INVULN);
    else
      this.management = (byte) (this.management | FLASH_NONE);
    
    if ((this.management & 0b11) != oldFT) refreshing = true;
  }
  
  abstract void act(); // The thing this enemy component does
  
  abstract void prePaint(); // Apply tints before painting
  
  abstract void paint(); // What this component looks like; draw() was taken by Processing
  
}


class TestComp extends EnemyComp {

  TestComp(short x, short y) {
    this.parent = null;
    this.x = x;
    this.y = y;
    this.boxWidth = 50;
    this.boxHeight = 25;
    this.health = 100;
    this.maxHealth = 100;
    
    this.management = (byte) (this.management | 0b11000); // They are in fact vulnerable and airborne
  }
  
  void act() {
    
    if (frameCount % 20 == 0) {println(this.health);}
    
  }
  
  void prePaint() {
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(223, 223, 223);
        break;
      
      case FLASH_TICK:
        fill(255, 255, 255);
        break;
      
      case FLASH_LOW:
        fill(223, 0, 0);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
  }
  
  void paint() {
    
    rect(x - 25, y - 12, 50, 25);
  
  }

}


class DollarStoreHibachi extends EnemyComp {
  
  short p1Dir1 = 0, p1Dir2 = 0, p2Spd = 2, p2Count = 16;
  
  DollarStoreHibachi(short x, short y) {
    this.parent = null;
    this.x = x;
    this.y = y;
    this.boxWidth = 25;
    this.boxHeight = 25;
    this.health = 1000;
    this.maxHealth = 1000;
  }
  
  void act() {
    
    // If the player is invulnerable, so are we
    if (p1IFrames + p2IFrames > 0)
      this.management = (byte) (this.management | 0b1000);
    else 
      this.management = (byte) (this.management & 0b11110111);
    
    if (frameCount % 8 != 0) {return;}
    
    println(this.health);
    
    if (frameCount % 320 <= 240) {
      
      this.p2Spd = 2;
      this.p2Count = 16;
      
      this.p1Dir1 += 5;
      this.p1Dir2 -= 6;
      
      // Drying machine
      
      for (byte i = 0; i < 16; i++) {
        addBullet(this.x, this.y, (short) (p1Dir1 + i * 22.5), (byte) 3, B_ORANGEBALL, (byte) 2);
        addBullet(this.x, this.y, (short) (p1Dir2 + i * 22.5), (byte) 5, B_BLUEBALL, (byte) 3);
      }
      
    } else {
      
      if (frameCount % 2 == 0) {p2Spd++;}
      p2Count += 4;
      
      for (byte i = 0; i < p2Count; i++) {
        addBullet(this.x, this.y - 20, (short) (pointTo(this.x, this.y, p1X, p1Y) + ((i - ((double) p2Count / 2)) * (180 / p2Count))), (byte) p2Spd, B_PINKBALL, (byte) (p2Count > 16 ? 2 : 3));
      }
      
    }
    
  }
  
  void prePaint() {
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(223, 223, 223);
        break;
      
      case FLASH_TICK:
        fill(255, 255, 255);
        break;
      
      case FLASH_LOW:
        fill(223, 0, 0);
        break;
      
      case FLASH_INVULN:
        fill(63, 63, 255);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
  }
  
  void paint() {
    
    circle(this.x, this.y, 25);
    
  }
  
}
