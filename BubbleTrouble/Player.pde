import processing.sound.*;
// ------------------------------------------------------------
// Globalne varijable i enumeracije vezane uz igrača.
// ------------------------------------------------------------
// Zadana visina sličice igrača. Na temelju nje i veličine
// originalne slike se računa širina playerImgWidth sličice u 
// Player.draw().
float playerImgHeight;
float playerImgWidth;

// Zadana širina i visina sličice koplja.
final float spearImgWidth = 20;
// Visina koplja se računa jednom u setup(), nakon učitavanja
// slike koplja.
float spearImgHeight; 

enum PlayerOrientation {
  BACK,
  LEFT,
  RIGHT
}
enum PlayerState {
  REGULAR,
  SHIELD
}

// ------------------------------------------------------------
// Klasa koja predstavlja igrača, uključujući koplje.
// ------------------------------------------------------------
class Player {
  // Pozicija igrača je određena x-koordinatom sredine sličice.
  float position;
  // Broj preostalih života.
  int lives = 4;
  // Kod igrača.
  int no_player;
  // Broj ostvarenih bodova u jednom levelu.
  int level_points = 0;
  // Broj ostvarenih bodova u igri.
  int overall_points = 0;

  // Pozicija glave koplja.
  float xSpear, ySpear;
  // Koplje je aktivno/trenutno ide prema gore.
  boolean spearActive = false, spearUp = false;
  
  // Pomoćna varijabla koja detektira je li igrač nedavno izgubio život.
  boolean just_lost_life = false;
  
  //zvuk koji se reproducira kad igrač izbaci koplje
  SoundFile shootingSound = getShootingSound();
  boolean soundOn = getSound();
  
  private PlayerOrientation orientation;
  private PlayerState state;
  
  // ----------------------------------------------------------
  // Metode
  // ----------------------------------------------------------
  Player(float _position, int number) {
    position = _position;
    ySpear = gameHeight; // Na dnu prozora s igrom.
    no_player = number;
    
    playerImgHeight = 65;
    
    this.orientation = PlayerOrientation.BACK;
    this.state = PlayerState.REGULAR;
  }
  
  // ----------------------------------------------------------
  // Iscrtavanje igrača na ekran.
  void draw() {
    fill(0);
    // Je li igrač trenutno na lijevom ili desnom rubu igre.
    Boolean leftEdge = (position - playerImgWidth/2) 
          <= ((windowWidth - gameWidth)/2);
    Boolean rightEdge = (position + playerImgWidth/2)
          >= ((windowWidth + gameWidth)/2);
          
    if (no_player == 1) {
      if (isLeft && !leftEdge) position = position - 3;
      if (isRight && !rightEdge) position = position + 3;
      if (isSpace && !spearActive)
        activateSpear();
    }
    if (no_player == 2) {
      if (isA && !leftEdge) position = position - 3;
      if (isD && !rightEdge) position = position + 3;
      if (isS && !spearActive)
        activateSpear();
    }
    
    int type = 0;
    switch(state){
      case REGULAR :
        playerImgHeight = 65;
        type = 0; 
        break;
      case SHIELD :
        playerImgHeight = 75;
        type = 3;
        break;
    }
    
    if (orientation == PlayerOrientation.LEFT){
      type++;
    }
    else if (orientation == PlayerOrientation.RIGHT){
      type += 2;
    }
    
    // Nacrtaj koplje (ako je aktivno).
    if (spearActive)
      image(spearImg, xSpear - spearImgWidth/2, ySpear,
          spearImgWidth, spearImgHeight);
    
    // Nacrtaj igrača.
    PImage img;
    if (no_player == 1)    
      img = player1_images.get(type);
    else
      img = player2_images.get(type);
      
    // Širina slike se računa tako da zadrži aspect ratio i bude visine
    // playerHeight.
    playerImgWidth = ((float)img.width / img.height) * playerImgHeight;
    // Position je sredina sličice.
    image(img, position - playerImgWidth/2, gameHeight - playerImgHeight, 
        playerImgWidth, playerImgHeight);
    
    fill(255);
  }
  
  // ----------------------------------------------------------
  // Resetiranje igračevih atributa.
  void resetPosition() {
    // Pozicija ovisi o kodu igrača i o ukupnom broju igrača:
    position = no_player*windowWidth/(quantity+1);
  }
  
  void resetOrientation() {
    orientation = PlayerOrientation.BACK;
  }
  
  void resetState() {
    state = PlayerState.REGULAR;
  }
  
  // ----------------------------------------------------------
  // Ažuriranje igračevih atributa.
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
  
  // ----------------------------------------------------------
  // Provjera kolizije sa supermoći (pravokutnik).
  boolean checkSuperpowerCollision(float xSuperpowerPosition, float ySuperpowerPosition) {

    if (position + playerImgWidth/2 + 5 >= xSuperpowerPosition &&
        position - playerImgWidth/2 + 14 <= xSuperpowerPosition + superpowerWidth &&
        gameHeight - playerImgHeight <= ySuperpowerPosition + superpowerHeight) {
          return true;
      }
      return false;
  }
  
  // ----------------------------------------------------------
  // Metode vezane uz koplje.
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
