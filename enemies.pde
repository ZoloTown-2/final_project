// Enemy flash type variables
final byte FLASH_NONE = 0; // Normal enemy image
final byte FLASH_TICK = 1; // Enemy being damaged (white tint)
final byte FLASH_LOW = 2; // Enemy at low health (red tint)
final byte FLASH_INVULN = 3; // Enemy that is invulnerable (blue tint)

// The rest
abstract class EnemyComp {
  
  EnemyComp[] children = new EnemyComp[0];
  EnemyComp parent;
  
  short x, y; // Becomes an offset if this enemy is a child; base x/y is based off of the parent's x/y
  short boxWidth, boxHeight; // Since "width" and "height" are taken by Processing (I'm sure it would still work but it just looks worrying in the editor)
  
  short health;
  short maxHealth;
  
  /*
    01234567
    
    0-1: Unused
    2: Passable (will the player shots simply pass by when hitting this enemy?)
    3: Airborne? (will the player get hit by this enemy if they run into them?)
    4: Invulnerable?
    5: Disposable? (are we removing this enemy next frame?)
    6-7: Flash/tint type
  */
  byte management;
  
  
  
  float getX() {return this.parent == null ? x : parent.getX() + x;}
  
  float getY() {return this.parent == null ? y : parent.getY() + y;}
  
  void damage(short amount) {
    if (((this.management & 0b1000) >> 3) == 1) return;
    
    this.health -= amount;
    
    if (this.health <= 0) {
      this.management = (byte) (this.management | 0b100);
      
      for (byte i = 0; i < children.length; i++) {
        children[i].management = (byte) (children[i].management | 0b100);
      }
    }
    
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
  
  void addComp(EnemyComp comp) {
    comp.parent = this;
    
    EnemyComp[] temp = new EnemyComp[children.length + 1];
    
    for (short i = 0; i < children.length; i++) {
      temp[i] = children[i];
    }
    
    temp[temp.length - 1] = comp;
    
    children = temp;
  }
  
  void removeComp(EnemyComp comp) {
    EnemyComp[] temp = new EnemyComp[children.length - 1];
    boolean skipped = false;
    
    for (short i = 0; i < children.length; i++) {
      
      if (children[i] == comp) {skipped = true; children[i].parent = null; continue;}
      
      temp[skipped ? i - 1 : i] = children[i];
      
    }
    
    children = temp;
  }
  
  abstract void init(); // Post-constructor initialization (typically for adding child EnemyComps)
  
  abstract void act(); // The thing this enemy component does
  
  abstract void paint(); // What this component looks like; draw() was taken by Processing
  
}


// Enemies


// Stage 1: Tank
class S1Tank extends EnemyComp {
  
  float point = 0;
  boolean hasCover = false;
  
  S1Tank(short x, short y) {
    this.parent = null;
    this.x = x;
    this.y = y;
    this.boxWidth = 100;
    this.boxHeight = 75;
    this.health = 1000;
    this.maxHealth = 1000;
  }
  
  void init() {
    // This is where we put the components of the enemy
    EnemyComp[] comps = {
      new S1Cover(this, (short) 0, (short) -85),
      new S1Cannon(this, (short) -70, (short) -75),
      new S1Cannon(this, (short) 70, (short) -75),
      new S1FlapCannon(this, (short) -65, (short) 20, (byte) 0, true),
      new S1FlapCannon(this, (short) 65, (short) 20, (byte) 0, true),
      new S1FlapCannon(this, (short) -65, (short) 65, (byte) 15, false),
      new S1FlapCannon(this, (short) 65, (short) 65, (byte) 15, false),
      new S1Turret(this, (short) -65, (short) -20, true),
      new S1Turret(this, (short) 65, (short) -20, false)
    };
    
    for (byte i = 0; i < comps.length; i++) {
      addEnemy(comps[i]);
      this.addComp(comps[i]);
    }
  }
  
  void act() {
    
    hasCover = false;
    
    for (byte i = 0; i < children.length; i++) {
      if (children[i] instanceof S1Cover) {hasCover = true; break;}
    }
    
    if (hasCover)
      this.management = (byte) (management | 0b101000);
    else {
      this.management = (byte) (management & 0b11010111);
      
      if (simulatedFrames % 60 == 0) {
        point = random(0, 22.5);
        
        float anger = (float) Math.pow(2, (6 - children.length)); // I guess we don't have the ^ operator
        
        for (byte i = 0; i < anger; i++) {
          switch (i % 4) {
            
            case 0:
              addBullet(getX(), getY(), point + (i * (360 / anger)), (byte) 5, B_ORANGEBALL, (byte) 6);
              break;
              
            case 1:
            case 3:
              addBullet(getX(), getY(), (short) (point + (i * (360 / anger))), (byte) 4, B_ORANGEBALL, (byte) 6);
              break;
              
            case 2:
              addBullet(getX(), getY(), (short) (point + (i * (360 / anger))), (byte) 3, B_ORANGEBALL, (byte) 6);
              break;
            
          }
        }
      }
    }
    
  }
  
  void paint() {
    
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(0, 127, 0);
        break;
      
      case FLASH_TICK:
        fill(63, 159, 63);
        break;
      
      case FLASH_LOW:
        fill(127, 95, 0);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    rect(x - 100, y - 125, 200, 250);
    
  }
  
}

// S1 Tank's core cover (shoots 3x8 pink bullets occasionally)
class S1Cover extends EnemyComp {
  
  float point = 0;
  boolean patternDir = false;
  
  S1Cover(EnemyComp parent, short x, short y) {
    this.parent = parent;
    this.x = x;
    this.y = y;
    this.boxWidth = 60;
    this.boxHeight = 45;
    this.health = 600;
    this.maxHealth = 600;
  }
  
  void init() {}
  
  void act() {
    
    byte destScore = 0;
    
    for (byte i = 0; i < parent.children.length; i++) {
      
      if (parent.children[i] instanceof S1Turret) destScore += 3;
      else if (parent.children[i] instanceof S1Cannon) destScore += 2;
      else if (parent.children[i] instanceof S1FlapCannon) destScore += 1;
      
    }
    
    switch (simulatedFrames % 120) {
      
      case 111:
        if (destScore > 12) return;
        
        point = (float) pointTo((short) getX(), (short) getY(), p1X, p1Y);
        patternDir = !patternDir;
        for (byte i = 0; i < 8; i++) {
          addBullet(getX(), getY(), (short) ((patternDir ? (point - 10) : (point + 10)) + i * 45), (byte) 2, B_PINKBALL, (byte) 7);
        }
        break;
      
      case 115:
        if (destScore > 8) return;
        
        for (byte i = 0; i < 8; i++) {
          addBullet(getX(), getY(), (short) (point + i * 45), (byte) 3, B_PINKBALL, (byte) 7);
        }
        break;
      
      case 119:
        if (destScore > 4) return;
        
        for (byte i = 0; i < 8; i++) {
          addBullet(getX(), getY(), (short) ((patternDir ? (point + 10) : (point - 10)) + i * 45), (byte) 4, B_PINKBALL, (byte) 7);
        }
        break;
      
    }
    
  }
  
  void paint() {
    
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(63, 63, 63);
        break;
      
      case FLASH_TICK:
        fill(159, 159, 159);
        break;
      
      case FLASH_LOW:
        fill(127, 31, 31);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    rect(getX() - 30, getY() - 22.5, 60, 45);
    
  }
  
}

// S1 Tank's large cannons (occasionally shoots big aimed yellow bullets)
class S1Cannon extends EnemyComp {
  
  byte recoil = 0;
  
  S1Cannon(EnemyComp parent, short x, short y) {
    this.parent = parent;
    this.x = x;
    this.y = y;
    this.boxWidth = 50;
    this.boxHeight = 50;
    this.health = 200;
    this.maxHealth = 200;
  }
  
  void init() {}
  
  void act() {
    
    if (simulatedFrames % 60 == 0) {
      
      double point = Math.toRadians(pointTo((short) getX(), (short) getY(), p1X, p1Y));
      
      addBullet((float) (getX() + Math.sin(point) * 10), (float) (getY() + Math.cos(point) * 10), (short) pointTo((short) getX(), (short) getY(), p1X, p1Y), (byte) 5, B_YELLOWLARGE, (byte) 15);
      recoil = 100;
      
    }
    
    recoil *= 0.8;
    
  }
  
  void paint() {
    
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(63, 63, 63);
        break;
      
      case FLASH_TICK:
        fill(159, 159, 159);
        break;
      
      case FLASH_LOW:
        fill(127, 31, 31);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    circle(getX(), getY(), 50);
    
    pushMatrix();
    translate(getX(), getY());
    rotate((float) (0 - Math.toRadians(pointTo((short) getX(), (short) getY(), p1X, p1Y))));
    rect(-12.5, -25 - recoil / 10, 25, 50);
    popMatrix();
    
  }
  
}

// S1 Tank's flap cannons (the ones that peek out from protection every now and then)
class S1FlapCannon extends EnemyComp {
  
  byte delay;
  boolean patternType;
  
  S1FlapCannon(EnemyComp parent, short x, short y, byte delay, boolean type) {
    this.parent = parent;
    this.x = x;
    this.y = y;
    this.boxWidth = 50;
    this.boxHeight = 25;
    this.health = 75;
    this.maxHealth = 75;
    
    this.management = (byte) 0b101000;
    
    this.delay = delay;
    this.patternType = type;
  }
  
  void init() {}
  
  void act() {
    
    switch ((simulatedFrames + delay) % 140) {
      
      case 0:
        this.management = (byte) (management | 0b101000);
        break;
      
      case 110:
        this.management = (byte) (management & 0b11010111);
        if (patternType) {
          addBullet(getX(), getY(), (float) pointTo((short) getX(), (short) getY(), p1X, p1Y), (byte) 4, B_ORANGEBALL, (byte) 5);
          addBullet(getX(), getY(), (float) (pointTo((short) getX(), (short) getY(), p1X, p1Y) - 30), (byte) 4, B_ORANGEBALL, (byte) 5);
          addBullet(getX(), getY(), (float) (pointTo((short) getX(), (short) getY(), p1X, p1Y) + 30), (byte) 4, B_ORANGEBALL, (byte) 5);
        } else {
          addBullet(getX(), getY(), (float) (pointTo((short) getX(), (short) getY(), p1X, p1Y) - 45), (byte) 4, B_ORANGEBALL, (byte) 5);
          addBullet(getX(), getY(), (float) (pointTo((short) getX(), (short) getY(), p1X, p1Y) - 15), (byte) 4, B_ORANGEBALL, (byte) 5);
          addBullet(getX(), getY(), (float) (pointTo((short) getX(), (short) getY(), p1X, p1Y) + 15), (byte) 4, B_ORANGEBALL, (byte) 5);
          addBullet(getX(), getY(), (float) (pointTo((short) getX(), (short) getY(), p1X, p1Y) + 45), (byte) 4, B_ORANGEBALL, (byte) 5);
        }
        patternType = !patternType;
        break;
      
    }
    
  }
  
  void paint() {
    
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(63, 63, 63);
        break;
      
      case FLASH_TICK:
        fill(159, 159, 159);
        break;
      
      case FLASH_LOW:
        fill(127, 31, 31);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    rect(getX() - 25, getY() - 12.5, 50, 25);
    
  }
  
}

// S1 Tank's multi-purpose turrets (the ones that shoots all around or create "lines")
class S1Turret extends EnemyComp {
  
  float point;
  boolean turningDirection;
  
  S1Turret(EnemyComp parent, short x, short y, boolean direction) {
    this.parent = parent;
    this.x = x;
    this.y = y;
    this.boxWidth = 35;
    this.boxHeight = 35;
    this.health = 150;
    this.maxHealth = 150;
    
    this.turningDirection = direction;
  }
  
  void init() {}
  
  void act() {
    if (simulatedFrames % 420 > 300 && simulatedFrames % 8 == 0) {
      
      addBullet(getX(), getY(), point, (byte) 5, B_BLUEBALL, (byte) 3);
      addBullet(getX(), getY(), point + 90, (byte) 5, B_BLUEBALL, (byte) 3);
      addBullet(getX(), getY(), point + 180, (byte) 5, B_BLUEBALL, (byte) 3);
      addBullet(getX(), getY(), point - 90, (byte) 5, B_BLUEBALL, (byte) 3);
      
      point += turningDirection ? -30 : 30;
      point %= 360;
      
    }
  }
  
  void paint() {
    
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(63, 63, 63);
        break;
      
      case FLASH_TICK:
        fill(159, 159, 159);
        break;
      
      case FLASH_LOW:
        fill(127, 31, 31);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    circle(getX(), getY(), 35);
    
  }
  
}
