import processing.sound.*;

enum PlayerOrientation {
  BACK,
  LEFT,
  RIGHT
}
enum PlayerState {
  REGULAR,
  SHIELD
}

// Klasa koja predstavlja igrača, uključujući koplje.
class Player {
  // Pozicija igrača je određena x-koordinatom sredine sličice.
  float position;
  // Broj preostalih života.
  int lives = 4;
  // Kod igrača.
  int no_player;
  // Broj ostvarenih bodova.
  int points = 0;

  // Pozicija glave koplja.
  float xSpear, ySpear;
  // Koplje je aktivno/trenutno ide prema gore.
  boolean spearActive = false, spearUp = false;
  
  //zvuk koji se reproducira kad igrač izbaci koplje
  SoundFile shootingSound = getShootingSound();
  boolean soundOn = getSound();
  
  private PlayerOrientation orientation;
  private PlayerState state;


  Player(float _position, int number) {
    position = _position;
    ySpear = gameHeight; // Na dnu prozora s igrom.
    no_player = number;
    
    this.orientation = PlayerOrientation.BACK;
    this.state = PlayerState.REGULAR;
  }

  // Iscrtavanje igrača na ekran.
  void draw() {
    fill(0);
    if (no_player == 1) {
      if (isLeft) position = position - 2;
      if (isRight) position = position + 2;
      if (isSpace && !spearActive)
        activateSpear();
    }
    if (no_player == 2) {
      if (isA) position = position - 2;
      if (isD) position = position + 2;
      if (isS && !spearActive)
        activateSpear();
    }
    
    int type = 0;
    switch(state){
      case REGULAR :
        type = 0; 
        break;
      case SHIELD : //kad uvedemo supermoći
        type = 3;
        break;
    }
    
    if (orientation == PlayerOrientation.LEFT){
      type++;
    }
    else if (orientation == PlayerOrientation.RIGHT){
      type += 2;
    }
    
    PImage img;
    if (no_player == 1)    
      img = player1_images.get(type);
    else
      img = player2_images.get(type);

    // Position je sredina sličice.
    image(img , position - 15, gameHeight - 50, 30, 50 );
    // Nacrtaj koplje (ako je aktivno).
    if (spearActive)
      rect(xSpear - 1, ySpear, 2, gameHeight - ySpear);

    fill(255);
  }

  void move(float x) {
    position += x;
  }

  void resetPosition() {
    // Pozicija ovisi o kodu igrača i o ukupnom broju igrača:
    position = no_player*windowWidth/(quantity+1) - 25;
  }

  void resetOrientation() {
    orientation = PlayerOrientation.BACK;
  }
  
  void resetState() {
    state = PlayerState.REGULAR;
  }
  
  // Ažuriraj koplje i sve što treba.
  void update() {
    if (spearActive) {
      // Koplje je stiglo do ruba ekrana, treba se početi spuštati.
      if (ySpear <= 0)
        spearUp = false;
      if (spearUp)      
        ySpear -= 16;
      else
        ySpear += 16;
      // Koplje se spustilo do kraja, postaje neaktivno.
      if (ySpear >= gameHeight){
        spearActive = false;
        shootingSound.stop();
      }
    }
  }

  void activateSpear() {
    xSpear = position; // Koplje počinje na trenutnoj poziciji igrača.
    spearActive = true;
    spearUp = true;
    if(soundOn)
      shootingSound.play();
  }

  void resetSpear() {
    spearActive = false;
    ySpear = gameHeight;
  }

  boolean isSpearActive() { 
    return spearActive;
  }
  
  void stopSpearSound(){
     shootingSound.stop();
  }
}
