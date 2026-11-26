// Enemy flash type variables
final byte FLASH_NONE = 0; // Normal enemy image
final byte FLASH_TICK = 1; // Enemy being damaged (white tint)
final byte FLASH_LOW = 2; // Enemy at low health (red tint)
final byte FLASH_INVULN = 3; // Enemy that is invulnerable (blue tint)

// Shared variables (between multiple enemies)
float s2P3PointOffset = 0;
byte s2Phase = 0;
boolean s1LCReady = false; // Left cannon ready?
boolean s1RCReady = false; // Right cannon ready?
boolean s3PhaseTwo = false;

// Drawing methods (I had to place every coordinate individually myself here)
void drawDestruction(float x, float y, float wid, float hei) {
  // This is because this script is based off of one I was using earlier that had the dimensions of 30x30
  wid /= 30;
  hei /= 30;
  
  beginShape();
  vertex(x - wid * 14, y - hei * 12);
  vertex(x - wid * 8, y - hei * 8);
  vertex(x, y - hei * 11);
  vertex(x + wid * 7, y - hei * 7);
  vertex(x + wid * 13, y - hei * 11);
  vertex(x + wid * 16, y - hei * 7);
  vertex(x + wid * 19, y - hei * 8);
  vertex(x + wid * 15, y - hei * 2);
  vertex(x + wid * 20, y - hei * 4);
  vertex(x + wid * 17, y + hei * 10);
  vertex(x + wid * 19, y + hei * 13);
  vertex(x + wid * 14, y + hei * 11);
  vertex(x + wid * 9, y + hei * 14);
  vertex(x - wid * 1, y + hei * 10);
  vertex(x - wid * 7, y + hei * 15);
  vertex(x - wid * 13, y + hei * 12);
  vertex(x - wid * 17, y + hei * 13);
  vertex(x - wid * 15, y + hei * 8);
  vertex(x - wid * 18, y + hei * 1);
  vertex(x - wid * 15, y - hei * 6);
  vertex(x - wid * 20, y - hei * 10);
  vertex(x - wid * 18, y - hei * 12);
  endShape(CLOSE);
}

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
      (frameType && subFrameType && this.health < this.maxHealth / 8) || // Very low health, flash quickly
      (frameType && subFrameType && subSubFrameType && this.health < this.maxHealth / 4) // Low health, flash moderately
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


// Non-bullet projectiles


class BombProjectile extends EnemyComp {
  
  float point;
  short targetX, targetY;
  short lifeTime;
  byte speed;
  
  BombProjectile(short ax, short ay, short bx, short by) {
    this.parent = null;
    this.x = ax;
    this.y = ay;
    this.management = 0b00101000; // Passable + Invulnerable
    
    this.targetX = bx;
    this.targetY = by;
    this.point = (float) pointTo(ax, ay, bx, by);
    this.speed = (byte) (dist(ax, ay, bx, by) / 5);
  }
  
  void init() {}
  
  void act() {
    
    lifeTime++;
    
    if (lifeTime == 60) {
      addBullet(getX(), getY(), 0, (byte) 120, B_BOMB, (byte) 25); // bulletSpd becomes duration for bombs, so "(byte) 120" is saying 120 frame-long lifespan for this explosion
      this.management = (byte) (management | 0b100); // Dispose
    }
    
    this.x += Math.sin(Math.toRadians(point)) * (double) speed / 2;
    this.y += Math.cos(Math.toRadians(point)) * (double) speed / 2;
    
    speed *= 0.945;
    
    refreshing = true;
    
  }
  
  void paint() {
    
    fill(127, 127, 95);
    
    if (lifeTime % 20 <= 1) {
      circle(getX(), getY(), 30);
      fill(255, 0, 0);
      circle(getX(), getY(), 15);
    } else {
      circle(getX(), getY(), 24);
      fill(255, 0, 0);
      circle(getX(), getY(), 12);
    }
    
  }
  
}



// Enemies


// Stage 1: Tank
class S1Tank extends EnemyComp {
  
  float point = 0;
  boolean hasCover = false;
  boolean previousSSFT = !subSubFrameType; // Refresh on subSubFrameType value change for the tires to apply visual changes
  
  S1Tank(short x, short y) {
    this.parent = null;
    this.x = x;
    this.y = y;
    this.boxWidth = 75;
    this.boxHeight = 50;
    this.health = 1000;
    this.maxHealth = 1000;
  }
  
  void init() {
    // This is where we put the components of the enemy
    EnemyComp[] comps = {
      new S1Cover(this, (short) 0, (short) 15),
      new S1Cannon(this, (short) -70, (short) 25, true),
      new S1Cannon(this, (short) 70, (short) 25, false),
      new S1FlapCannon(this, (short) -65, (short) 120, (byte) 0),
      new S1FlapCannon(this, (short) 65, (short) 120, (byte) 0),
      new S1FlapCannon(this, (short) -65, (short) 165, (byte) 15),
      new S1FlapCannon(this, (short) 65, (short) 165, (byte) 15),
      new S1Turret(this, (short) -65, (short) 80, true),
      new S1Turret(this, (short) 65, (short) 80, false)
    };
    
    for (byte i = 0; i < comps.length; i++) {
      addEnemy(comps[i]);
      this.addComp(comps[i]);
    }
  }
  
  void act() {
    
    hasCover = false;
    
    // Update the wheel tracks if it's time for them to do so
    if (previousSSFT != subSubFrameType) refreshing = true;
    previousSSFT = subSubFrameType;
    
    byte turrets = 0;
    
    for (byte i = 0; i < children.length; i++) {
      if (children[i] instanceof S1Cover) {hasCover = true; continue;}
      if (children[i] instanceof S1Turret) {turrets++; continue;}
    }
    
    s1LCReady = turrets < 2;
    s1RCReady = turrets < 1;
    
    if (!hasCover) {
      for (byte i = 0; i < children.length; i++) {
        if (!(children[i] instanceof S1Cannon)) {children[i].management = (byte) (children[i].management | 0b100);}
      }
    }
    
    if (hasCover)
      this.management = (byte) (management | 0b101000);
    else {
      this.management = (byte) (management & 0b11010111);
      
      if (simulatedFrames % 60 == 0) {
        point = random(0, 22.5);
        
        // I don't know what else to call this
        float anger = (float) Math.pow(2, (6 - children.length)); // I guess we don't have the ^ operator
        
        for (byte i = 0; i < anger; i++) {
          switch ((anger > 8) ? i % 4 : 0) {
            
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
        fill(31, 159, 31);
        break;
      
      case FLASH_LOW:
        fill(127, 95, 0);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    // Base
    rect(getX() - 100, getY() - 25, 200, 250);
    
    // Destroyed components
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(0, 31, 0);
        break;
      
      case FLASH_TICK:
        fill(31, 63, 31);
        break;
      
      case FLASH_LOW:
        fill(63, 15, 0);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    strokeWeight(0);
    
    // Cover
    drawDestruction(getX(), getY() + 10, 35, 35);
    
    // Cannons
    drawDestruction(getX() - 70, getY() + 15, 20, 20);
    drawDestruction(getX() + 70, getY() + 15, 20, 20);
    
    // Flap cannons
    drawDestruction(getX() - 60, getY() + 120, 30, 20);
    drawDestruction(getX() + 60, getY() + 120, 30, 20);
    drawDestruction(getX() - 60, getY() + 165, 30, 20);
    drawDestruction(getX() + 60, getY() + 165, 30, 20);
    
    // Turret
    drawDestruction(getX() - 62, getY() + 80, 20, 23);
    drawDestruction(getX() + 62, getY() + 80, 20, 23);
    
    // Misc. components
    strokeWeight(1);
    
    // Thing in the middle
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(63, 95, 63);
        break;
      
      case FLASH_TICK:
        fill(127, 159, 127);
        break;
      
      case FLASH_LOW:
        fill(127, 63, 31);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    rect(getX() - 15, getY() + 60, 30, 140);
    
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(63, 63, 63);
        break;
      
      case FLASH_TICK:
        fill(127, 127, 127);
        break;
      
      case FLASH_LOW:
        fill(127, 31, 31);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    // Wheels
    /*
      rect(getX() - 120, getY() - 125, 20, 250);
      rect(getX() + 100, getY() - 125, 20, 250);
    */
    beginShape();
    vertex(getX() - 120, getY() - 15);
    vertex(getX() - 110, getY() - 25);
    vertex(getX() - 100, getY() - 25);
    vertex(getX() - 100, getY() + 225);
    vertex(getX() - 110, getY() + 225);
    vertex(getX() - 120, getY() + 215);
    endShape(CLOSE); // OPEN messes with the stroke/outlines
    
    beginShape();
    vertex(getX() + 100, getY() - 25);
    vertex(getX() + 110, getY() - 25);
    vertex(getX() + 120, getY() - 15);
    vertex(getX() + 120, getY() + 215);
    vertex(getX() + 110, getY() + 225);
    vertex(getX() + 100, getY() + 225);
    endShape(CLOSE);
    
    // Wheel tracks
    for (byte i = 0; i < 13; i++) {
      line(getX() - (subSubFrameType ? (((i == 0 || i == 12) ? 115 : 120)) : 120), getY() + (i - 6) * 20 + 100 + (subSubFrameType ? 0 : 10), getX() - 100, getY() + (i - 6) * 20 + 100 + (subSubFrameType ? 0 : 10));
      line(getX() + 100, getY() + (i - 6) * 20 + 100 + (subSubFrameType ? 0 : 10), getX() + (subSubFrameType ? (((i == 0 || i == 12) ? 115 : 120)) : 120), getY() + (i - 6) * 20 + 100 + (subSubFrameType ? 0 : 10));
    }
    
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
  boolean leftSide;
  boolean targetPly;
  
  S1Cannon(EnemyComp parent, short x, short y, boolean side) {
    this.parent = parent;
    this.x = x;
    this.y = y;
    this.boxWidth = 50;
    this.boxHeight = 50;
    this.health = 200;
    this.maxHealth = 200;
    
    this.leftSide = side;
  }
  
  void init() {}
  
  void act() {
    
    if (simulatedFrames % 60 == 0) {
      
      if ((leftSide ? s1LCReady : s1RCReady)) {
        
        this.management = (byte) (management & 0b11010111);
        
        double point = Math.toRadians(pointTo((short) getX(), (short) getY(), p1X, p1Y));
        
        addBullet((float) (getX() + Math.sin(point) * 10), (float) (getY() + Math.cos(point) * 10), (short) pointTo((short) getX(), (short) getY(), plyX(targetPly), plyY(targetPly)), (byte) 5, B_YELLOWLARGE, (byte) 15);
        recoil = 100;
        
        targetPly = !targetPly;
        
      } else {
        
        this.management = (byte) (management | 0b101000); // Passable + Invulnerable
        
      }
      
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
    
    if (leftSide ? s1LCReady : s1RCReady) {
      
      pushMatrix();
      translate(getX(), getY());
      rotate((float) (0 - Math.toRadians(pointTo((short) getX(), (short) getY(), plyX(targetPly), plyY(targetPly)))));
      rect(-12.5, -25 - recoil / 10, 25, 50);
      popMatrix();
      
    } else {
      
      line(getX() - 25, getY(), getX() + 25, getY());
      
    }
    
  }
  
}

// S1 Tank's flap cannons (the ones that peek out from protection every now and then)
class S1FlapCannon extends EnemyComp {
  
  byte delay;
  boolean patternType = true;
  
  S1FlapCannon(EnemyComp parent, short x, short y, byte delay) {
    this.parent = parent;
    this.x = x;
    this.y = y;
    this.boxWidth = 50;
    this.boxHeight = 25;
    this.health = 75;
    this.maxHealth = 75;
    
    this.management = (byte) 0b101000;
    
    this.delay = delay;
  }
  
  void init() {}
  
  void act() {
    
    switch ((simulatedFrames + delay) % 140) {
      
      case 0:
        this.management = (byte) (management | 0b101000);
        break;
      
      case 110:
        this.management = (byte) (management & 0b11010111);
        boolean targetPly = nearestPlayer((short) getX(), (short) getY());
        if (patternType) {
          addBullet(getX(), getY(), (float) pointTo((short) getX(), (short) getY(), plyX(targetPly), plyY(targetPly)), (byte) 3, B_ORANGESPIKE, (byte) 5);
          addBullet(getX(), getY(), (float) (pointTo((short) getX(), (short) getY(), plyX(targetPly), plyY(targetPly)) - 30), (byte) 3, B_ORANGESPIKE, (byte) 5);
          addBullet(getX(), getY(), (float) (pointTo((short) getX(), (short) getY(), plyX(targetPly), plyY(targetPly)) + 30), (byte) 3, B_ORANGESPIKE, (byte) 5);
        } else {
          addBullet(getX(), getY(), (float) (pointTo((short) getX(), (short) getY(), plyX(targetPly), plyY(targetPly)) - 45), (byte) 3, B_ORANGESPIKE, (byte) 5);
          addBullet(getX(), getY(), (float) (pointTo((short) getX(), (short) getY(), plyX(targetPly), plyY(targetPly)) - 15), (byte) 3, B_ORANGESPIKE, (byte) 5);
          addBullet(getX(), getY(), (float) (pointTo((short) getX(), (short) getY(), plyX(targetPly), plyY(targetPly)) + 15), (byte) 3, B_ORANGESPIKE, (byte) 5);
          addBullet(getX(), getY(), (float) (pointTo((short) getX(), (short) getY(), plyX(targetPly), plyY(targetPly)) + 45), (byte) 3, B_ORANGESPIKE, (byte) 5);
        }
        patternType = !patternType;
        break;
      
    }
    
  }
  
  void paint() {
    
    if ((this.management & 0b1000) == 0b1000) {
      
      // Hidden
      
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
      
      line(getX() - 25, getY(), getX() + 25, getY());
      
    } else {
      
      // Revealed
      
      strokeWeight(0);
      
      switch (this.management & 0b11) {
        
        case FLASH_NONE:
          fill(31, 31, 31);
          break;
        
        case FLASH_TICK:
          fill(127, 127, 127);
          break;
        
        case FLASH_LOW:
          fill(95, 15, 15);
          break;
        
        default:
          println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
        
      }
      
      rect(getX() - 25, getY() - 12.5, 50, 25);
      
      for (byte i = 0; i < 4; i++) {
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
        circle(getX() + 5 + (i - 2) * 10, getY(), 8);
        
        switch (this.management & 0b11) {
          
          case FLASH_NONE:
            fill(15, 15, 15);
            break;
          
          case FLASH_TICK:
            fill(63, 63, 63);
            break;
          
          case FLASH_LOW:
            fill(31, 7, 7);
            break;
          
          default:
            println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
          
        }
        circle(getX() + 5 + (i - 2) * 10, getY(), 6);
      }
      
      strokeWeight(1);
      
    }
    
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
    
    
    strokeWeight(0);
    pushMatrix();
    translate(getX(), getY());
    rotate((float) (0 - Math.toRadians(point)));
    
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(15, 15, 15);
        break;
      
      case FLASH_TICK:
        fill(63, 63, 63);
        break;
      
      case FLASH_LOW:
        fill(31, 7, 7);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    circle(0, 10, 6);
    circle(0, -10, 6);
    circle(10, 0, 6);
    circle(-10, 0, 6);
    
    popMatrix();
    strokeWeight(1);
    
  }
  
}


// Stage 2: Fortress
class S2Fortress extends EnemyComp {
  
  short lifeTime = 0;
  boolean goingDown;

  S2Fortress(short x, short y) {
    this.x = x;
    this.y = y;
    this.boxWidth = 250;
    this.boxHeight = 50;
    this.health = 5999;
    this.maxHealth = 5999;
  }
  
  void init() {
    EnemyComp[] comps = {
      new S2Rotator(this, (short) -175, (short) 110, (byte) 0),
      new S2Rotator(this, (short) -175, (short) 275, (byte) 2),
      new S2Rotator(this, (short) 175, (short) 110, (byte) 1),
      new S2Rotator(this, (short) 175, (short) 275, (byte) 3),
      new S2MPTurret(this, (short) -180, (short) 180, true),
      new S2MPTurret(this, (short) 180, (short) 180, false),
      new S2Cannon(this, (short) -175, (short) 25, true),
      new S2Cannon(this, (short) 175, (short) 25, false)
    };
    
    for (byte i = 0; i < comps.length; i++) {
      addEnemy(comps[i]);
      this.addComp(comps[i]);
    }
  }
  
  void act() {
    
    s2Phase = (byte) (2 - health / 2000);
    
    if (s2Phase == 2) {
      lifeTime++;
      lifeTime %= 720;
      
      if (lifeTime < 600 && lifeTime % 60 < 30 && lifeTime % 2 == 0) {
        
        if (lifeTime % 60 == 0) {
          goingDown = s2P3PointOffset >= 45 ? false : (s2P3PointOffset <= -45 ? true : (Math.floor(random(0, 2)) == 1));
        }
        
        if (goingDown)
          s2P3PointOffset += 1;
        else
          s2P3PointOffset -= 1;
        
      }
    }
    
  }
  
  void paint() {
    
    // Fortress
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(63, 63, 63);
        break;
      
      case FLASH_TICK:
        fill(95, 95, 95);
        break;
      
      case FLASH_LOW:
        fill(95, 31, 31);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    beginShape();
    vertex(getX() - 200, getY());
    vertex(getX() + 200, getY());
    vertex(getX() + 200, getY() + 325);
    vertex(getX() + 150, getY() + 325);
    vertex(getX() + 150, getY() + 50);
    vertex(getX() - 150, getY() + 50);
    vertex(getX() - 150, getY() + 325);
    vertex(getX() - 200, getY() + 325);
    endShape(CLOSE);
    
    // Decoration thing (moreso an indicator of where you should shoot)
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(127, 127, 127);
        break;
      
      case FLASH_TICK:
        fill(195, 195, 195);
        break;
      
      case FLASH_LOW:
        fill(195, 127, 127);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    rect(getX() - 125, getY() + 13, 250, 25);
    
  }

}

// S2 Fortress' turrets that occasionally shoot, rotating when they do
class S2Rotator extends EnemyComp {
  
  float point;
  short lifeTime = 0;
  byte frameOffset;
  
  S2Rotator(EnemyComp parent, short x, short y, byte offset) {
    this.parent = parent;
    this.x = x;
    this.y = y;
    this.boxWidth = 35;
    this.boxHeight = 35;
    this.health = 150;
    this.maxHealth = 150;
    
    this.frameOffset = (byte) (offset * 30);
    this.management = 0b1000;
  }
  
  void init() {}
  
  void act() {
    
    if (s2Phase > 1 && (this.management & 0b1000) == 0b1000) this.management = (byte) (management & 0b11110111);
    
    lifeTime++;
    lifeTime %= 720;
    short frames = (short) (lifeTime - frameOffset);
    
    if (frames >= 600 && frames < 630 && frames % 3 == 0) {
      for (byte i = 0; i < 2; i++) {
        addBullet(getX(), getY(), point + i * 180, (byte) 2, B_ORANGEBALL, (byte) 4);
      }
      
      point += 26;
      point %= 360;
    }
    
  }
  
  void paint() {
    
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(127, 127, 127);
        break;
      
      case FLASH_TICK:
        fill(195, 195, 195);
        break;
      
      case FLASH_LOW:
        fill(195, 127, 127);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    circle(getX(), getY(), 20);
    
    
    strokeWeight(0);
    pushMatrix();
    translate(getX(), getY());
    rotate((float) (0 - Math.toRadians(point)));
    
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(15, 15, 15);
        break;
      
      case FLASH_TICK:
        fill(63, 63, 63);
        break;
      
      case FLASH_LOW:
        fill(31, 7, 7);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    circle(0, 5, 4);
    circle(0, -5, 4);
    
    popMatrix();
    strokeWeight(1);
    
  }
  
}

// S2 Fortress' multi-purpose turrets
class S2MPTurret extends EnemyComp {
  
  float point = 0;
  short lifeTime = 0;
  byte phase = 0;
  boolean p3RightIsDown;
  boolean targetPly;
  
  S2MPTurret(EnemyComp parent, short x, short y, boolean side) {
    this.parent = parent;
    this.x = x;
    this.y = y;
    this.boxWidth = 35;
    this.boxHeight = 35;
    this.health = 150;
    this.maxHealth = 150;
    
    this.management = 0b1000;
    this.p3RightIsDown = side;
    this.targetPly = side;
  }
  
  void init() {}
  
  void act() {
    
    lifeTime++;
    lifeTime %= 720;
    
    // if (lifeTime == 0) {phase++; phase %= 3;}
    
    if (lifeTime == 0) phase = s2Phase;
    
    if (lifeTime < 600) {
      
      switch (phase) {
        
        // Whip
        case 0:
          if (lifeTime % 48 < 12 && lifeTime % 3 == 0 && lifeTime != 0) {
            point = (float) pointTo((short) getX(), (short) getY(), plyX(targetPly), plyY(targetPly));
            for (byte i = 0; i < 3; i++) {
              addBullet((short) (getX() + Math.sin(Math.toRadians(point) + Math.PI / 2) * ((i - 1) * 15)), (short) (getY() + Math.cos(Math.toRadians(point) + Math.PI / 2) * ((i - 1) * 15)), point, (byte) (2 + ((lifeTime % 24) / 3)), B_PINKBALL, (byte) 4);
            }
          }
          if (lifeTime % 48 == 12) targetPly = !targetPly;
          break;
        
        // Mortar
        case 1:
          if (lifeTime % 60 == 0) {
            addEnemy(new BombProjectile((short) getX(), (short) getY(), plyX(targetPly), plyY(targetPly)));
            targetPly = !targetPly;
          }
          break;
        
        // Fan(?)
        case 2:
          if ((this.management & 0b1000) == 0b1000) this.management = (byte) (management & 0b11110111);
          if (lifeTime == 0) {point = 0; s2P3PointOffset = 0;}
          if (lifeTime % 4 == 0 && (lifeTime > 96 || lifeTime % 32 == 0)) {
            for (byte i = 0; i < 7; i++) {
              if (i == 3) continue;
              addBullet(getX(), getY(), (point + (i - 3) * 22.5) + (s2P3PointOffset * (p3RightIsDown ? 1 : -1) + (p3RightIsDown ? 90 : -90)), (byte) (lifeTime <= 64 ? 4 : 8), B_BLUESPIKE, (byte) 3);
            }
          }
          if (lifeTime == 599) targetPly = !targetPly;
          break;
        
        default:
          println("Bogus S2MPTurret phase type (" + s2Phase + ")");
        
      }
      
    }
    
  }
  
  void paint() {
    
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(127, 127, 127);
        break;
      
      case FLASH_TICK:
        fill(195, 195, 195);
        break;
      
      case FLASH_LOW:
        fill(195, 127, 127);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    circle(getX(), getY(), 45);
    
    pushMatrix();
    translate(getX(), getY());
    rotate((float) (0 - Math.toRadians((phase == 2 ? (point + s2P3PointOffset * (p3RightIsDown ? 1 : -1) + (p3RightIsDown ? 90 : -90)) : pointTo((short) getX(), (short) getY(), plyX(targetPly), plyY(targetPly))))));
    rect(-25, 0, 50, 25);
    popMatrix();
    
  }
  
}

// S2 Fortress' large cannon similar to that of S1 Tank's
class S2Cannon extends EnemyComp {
  
  short lifeTime = 0;
  byte recoil = 0;
  boolean targetPly;
  
  S2Cannon(EnemyComp parent, short x, short y, boolean offsetTiming) {
    this.parent = parent;
    this.x = x;
    this.y = y;
    this.boxWidth = 35;
    this.boxHeight = 35;
    this.health = 150;
    this.maxHealth = 150;
    
    this.management = 0b1000;
    
    if (offsetTiming) lifeTime += 20; // 30 would be half, but I think I prefer 20
  }
  
  void init() {}
  
  void act() {
    
    if (s2Phase < 2) return;
    
    if ((this.management & 0b1000) == 0b1000) this.management = (byte) (management & 0b11110111);
    
    lifeTime++;
    lifeTime %= 720;
    
    if (lifeTime < 600 && lifeTime % 120 == 0) {
      
      double point = Math.toRadians(pointTo((short) getX(), (short) getY(), p1X, p1Y));
      
      addBullet((float) (getX() + Math.sin(point) * 10), (float) (getY() + Math.cos(point) * 10), (short) pointTo((short) getX(), (short) getY(), plyX(targetPly), plyY(targetPly)), (byte) 7, B_YELLOWLARGE, (byte) 12);
      recoil = 100;
      
      targetPly = !targetPly;
      
    }
    
    recoil *= 0.8;
    
  }
  
  void paint() {
    
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(127, 127, 127);
        break;
      
      case FLASH_TICK:
        fill(195, 195, 195);
        break;
      
      case FLASH_LOW:
        fill(195, 127, 127);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    circle(getX(), getY(), 50);
    
    if (s2Phase > 1) {
      
      pushMatrix();
      translate(getX(), getY());
      rotate((float) (0 - Math.toRadians(pointTo((short) getX(), (short) getY(), plyX(targetPly), plyY(targetPly)))));
      rect(-12.5, -25 - recoil / 10, 25, 50);
      popMatrix();
      
    } else {
      
      line(getX() - 25, getY(), getX() + 25, getY());
      
    }
    
  }
  
}




// Stage 3: Aircraft
class S3Aircraft extends EnemyComp {
  
  float point;
  short lifeTime;
  byte phase = 0;
  boolean targetPly;

  S3Aircraft(short x, short y) {
    this.x = x;
    this.y = y;
    this.boxWidth = 60;
    this.boxHeight = 60;
    this.health = 4000;
    this.maxHealth = 4000;
    
    this.management = 0b10000;
  }
  
  void init() {
    EnemyComp[] comps = {
      new S3Stabilizer(this),
      new S3Body(this)
    };
    
    for (byte i = 0; i < comps.length; i++) {
      addEnemy(comps[i]);
      this.addComp(comps[i]);
    }
  }
  
  void act() {
    byte temp = 2;
    
    for (byte i = 0; i < children.length; i++) {
      if (temp > 0 && children[i] instanceof S3Stabilizer) temp = 0;
      if (temp > 1 && children[i] instanceof S3Body) temp = 1;
    }
    
    phase = temp;
    s3PhaseTwo = phase == 1;
    
    if (phase == 2) {
      
      // Phase #3
      
      // Rapid aimed streams, frantic static patterns, lots of movement, sometimes go down to shoot upward, maybe add bombs
      
      lifeTime++;
      lifeTime %= 840;
      
      if (lifeTime < 150) {
        
        // Random shots
        
        addBullet(getX(), getY(), random(0, 360), (byte) random(2, 10), (byte) B_ORANGEBALL, (byte) 3);
        
      } else if (lifeTime < 300) {
        
        // Aimed static pattern
        
        if (lifeTime % 2 != 0) return;
        
        if (lifeTime == 150) {targetPly = randomPlayer(); point = (float) pointTo((short) getX(), (short) getY(), plyX(targetPly), plyY(targetPly));}
        
        for (byte i = 0; i < 4; i++) {
          addBullet(getX(), getY(), (i * 90) - point, (byte) 5, B_PINKBALL, (byte) 3);
          addBullet(getX(), getY(), point - (i * 90), (byte) 5, B_PINKBALL, (byte) 3);
        }
        
        point += 17;
        point %= 360;
        
      } else if (lifeTime < 450) {
        
        // Variable-width vollies + bombs
        
        if (lifeTime % 4 != 0) return;
        
        if (lifeTime == 300) targetPly = nearestPlayer((short) getX(), (short) getY());
        
        boolean attackType = lifeTime % 8 == 0;
        
        // This didn't turn out how I wanted it to but I don't really care at this point
        for (byte i = 0; i < (attackType ? 5 : 6); i++) {
          addBullet(getX(), getY(), (float) (pointTo((short) getX(), (short) getY(), plyX(targetPly), plyY(targetPly)) + (i - (attackType ? 2 : 2.5)) * (attackType ? 25 : 20.83)), (byte) 6, B_ORANGEBALL, (byte) 6);
        }
        
      } else if (lifeTime < 720) {
        
        // Go down to shoot up
        
        if (lifeTime % 4 != 0) return;
        
        if (lifeTime == 452) {this.y += 200; targetPly = nearestPlayer((short) getX(), (short) getY());}
        
        if (lifeTime < 570) return;
        
        for (byte i = 0; i < 8; i++) {
          
          if (lifeTime % 12 == 0)
            addBullet(getX(), getY(), (float) (pointTo((short) getX(), (short) getY(), plyX(targetPly), plyY(targetPly)) + (i - 4) * 12), (byte) 3, B_PINKBALL, (byte) 4);
          
          if (lifeTime % 16 == 0 && i != 7)
            addBullet(getX(), getY(), (float) (pointTo((short) getX(), (short) getY(), plyX(targetPly), plyY(targetPly)) + (i - 3) * 18), (byte) 5, B_PINKBALL, (byte) 4);
          
        }
        
        if (lifeTime == 716) this.y -= 200;
        
      }
      
    }
  }
  
  void paint() {
    
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(195, 195, 195);
        break;
      
      case FLASH_TICK:
        fill(223, 223, 223);
        break;
      
      case FLASH_LOW:
        fill(223, 195, 195);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    triangle(getX(), getY() - 40, getX() - 40, getY() + 40, getX() + 40, getY() + 40);
    
  }

}

// S3 Aircraft's body
class S3Body extends EnemyComp {
  
  float point;
  short lifeTime;
  
  S3Body(EnemyComp parent) {
    this.parent = parent;
    this.y = 80;
    this.boxWidth = 80;
    this.boxHeight = 100;
    this.health = 2000;
    this.maxHealth = 2000;
    
    this.management = 0b10000;
  }
  
  void init() {
    EnemyComp[] comps = {
      new S3Wing(this, false),
      new S3Wing(this, true)
    };
    
    for (byte i = 0; i < comps.length; i++) {
      addEnemy(comps[i]);
      this.addComp(comps[i]);
    }
  }
  
  void act() {
    
    lifeTime++;
    
    if (s3PhaseTwo) {
      
      // Phase #2
      
      lifeTime %= 630; // This can only be at most 5 frame off-sync with the S3Wings
      
      if (lifeTime >= 270 && lifeTime < 590 && lifeTime % 4 == 0) {  
        if (lifeTime == 270) point = 180;
        
        for (byte i = 0; i < 4; i++) {
          addBullet(getX(), getY(), point + (i * 90), (byte) 3, B_ORANGEBALL, (byte) 3);
          addBullet(getX(), getY(), 180 - point + (i * 90), (byte) 3, B_ORANGEBALL, (byte) 3);
        }
        
        point += 13;
        point %= 360;
      }
      
    } else {
      
      // Phase #1
      
      lifeTime %= 6;
      
      if (lifeTime == 0) {
        
        point += 15;
        
        for (byte i = 0; i < 3; i++) {
          addBullet(getX(), getY(), point - 120 * i, (byte) 4, B_PINKBALL, (byte) 5);
          addBullet(getX(), getY(), 120 * i - point, (byte) 4, B_PINKBALL, (byte) 5);
        }
        
      }
      
    }
    
  }
  
  void paint() {
    
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(195, 195, 195);
        break;
      
      case FLASH_TICK:
        fill(223, 223, 223);
        break;
      
      case FLASH_LOW:
        fill(223, 195, 195);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    rect(getX() - 40, getY() - 40, 80, 100);
    
  }
  
}

// S3 Aircraft's wings
class S3Wing extends EnemyComp {
  
  short lifeTime = 0;
  boolean rightSide;
  boolean targetPly;
  
  S3Wing(EnemyComp parent, boolean side) {
    this.parent = parent;
    this.x = (byte) (side ? 80 : -80);
    this.boxWidth = 160;
    this.boxHeight = 35;
    this.health = 1000;
    this.maxHealth = 1000;
    
    this.management = 0b10000;
    this.rightSide = side;
  }
  
  void init() {}
  
  void act() {
    if (s3PhaseTwo) {
      
      // Phase #2
      
      lifeTime++;
      lifeTime %= 630;
      
      if (lifeTime > 89 && lifeTime < 270 && lifeTime % 90 < 45 && lifeTime % 2 == 0) {
        if (lifeTime == 90) targetPly = nearestPlayer((short) getX(), (short) getY());
        for (byte i = 0; i < 6; i++) {
          short fx = (short) (getX() + i * 20 * (rightSide ? 1 : -1));
          short fy = (short) (getY() + 20 + i * 2);
          addBullet(fx, fy, (float) pointTo((short) fx, (short) fy, plyX(targetPly), plyY(targetPly)), (byte) 5, B_BLUEBALL, (byte) 2);
        }
      }
      
    } else {
      
      // Phase #1
      
      /*
        if (simulatedFrames % 4 == 0) {
          for (byte i = 0; i < 6; i++) {
            addBullet(getX() + (i + 4) * 20 * (rightSide ? 1 : -1), getY() + 20 + i * 2, 0, (byte) 12, B_BLUEBALL, (byte) 4);
          }
        }
      */
      
      byte simmedFrames = (byte) (simulatedFrames % 64);
      
      switch (simmedFrames) {
        
        case 0:
        case 2:
        case 4:
        case 6:
        case 8:
        case 10:
          addBullet(getX() + (simmedFrames / 2) * 20 * (rightSide ? 1 : -1), getY() + 20 + (simmedFrames / 2) * 3, 0, (byte) 5, B_BLUESPIKE, (byte) 3);
          break;
        
        case 32:
        case 34:
        case 36:
        case 38:
        case 40:
        case 42:
          addBullet(getX() + (5 - ((simmedFrames - 32) / 2)) * 20 * (rightSide ? 1 : -1), getY() + 20 + ((simmedFrames - 32) / 2) * 3, 0, (byte) 5, B_BLUESPIKE, (byte) 3);
          break;
        
      }
      
    }
  }
  
  void paint() {
    
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(195, 195, 195);
        break;
      
      case FLASH_TICK:
        fill(223, 223, 223);
        break;
      
      case FLASH_LOW:
        fill(223, 195, 195);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    triangle(getX() + (rightSide ? 120 : -120), getY() + 35, getX() + (rightSide ? -40 : 40), getY() - 35, getX() + (rightSide ? -40 : 40), getY() + 35);
    
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(127, 127, 127);
        break;
      
      case FLASH_TICK:
        fill(195, 195, 195);
        break;
      
      case FLASH_LOW:
        fill(195, 127, 127);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    triangle(getX() + (rightSide ? 120 : -120), getY() + 35, getX() + (rightSide ? -40 : 40), getY() + 10, getX() + (rightSide ? -40 : 40), getY() + 35);
    
  }
  
}

// S3 Aircraft's stabilizer-adjacent thing
class S3Stabilizer extends EnemyComp {
  
  S3Stabilizer(EnemyComp parent) {
    this.parent = parent;
    this.boxWidth = 120;
    this.boxHeight = 450;
    this.health = 500;
    this.maxHealth = 500;
    
    this.management = 0b10000;
  }
  
  void init() {}
  
  void act() {}
  
  void paint() {
    
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(195, 195, 195);
        break;
      
      case FLASH_TICK:
        fill(223, 223, 223);
        break;
      
      case FLASH_LOW:
        fill(223, 195, 195);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    //rect(getX() - 60, getY() + 110, 120, 35);
    //triangle(getX() - 60, getY() + 145, getX() + 60, getY() + 145, getX(), getY() + 110);
    rect(getX() - 15, getY() + 80, 30, 145);
    beginShape();
    vertex(getX() - 60, getY() + 225);
    vertex(getX() - 60, getY() + 215);
    vertex(getX() - 5, getY() + 190);
    vertex(getX() + 5, getY() + 190);
    vertex(getX() + 60, getY() + 215);
    vertex(getX() + 60, getY() + 225);
    endShape(CLOSE);
    
    switch (this.management & 0b11) {
      
      case FLASH_NONE:
        fill(127, 127, 127);
        break;
      
      case FLASH_TICK:
        fill(195, 195, 195);
        break;
      
      case FLASH_LOW:
        fill(195, 127, 127);
        break;
      
      default:
        println(this.getClass().getSimpleName() + ": Bogus enemy flash type: " + (this.management & 0b11));
      
    }
    
    rect(getX() - 60, getY() + 220, 120, 5);
    // triangle(getX() - 60, getY() + 225, getX(), getY() + 220, getX() + 60, getY() + 225);
    
  }
  
}
