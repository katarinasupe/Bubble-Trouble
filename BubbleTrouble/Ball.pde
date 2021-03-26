// ------------------------------------------------------------ //<>//
// Globalne varijable i enumeracije vezane uz loptice.
// ------------------------------------------------------------
enum BallColor {
  RED,
  BLUE,
  GREEN,
  ORANGE,
  PURPLE,
  YELLOW
}
HashMap<BallColor, PImage> ballImgs;

// Visine do kojih loptice različitih levela veličine skaču.
// Uvijek je isto za loptice istih veličina (ovisi o gameHeight)
// pa se računa samo jednom u setup().
float[] ballJumpHeight;
float[] splitBallJumpHeight; // Visina poskoka loptice nakon razbijanja.

// ------------------------------------------------------------
// Klasa koja predstavlja loptice.
// ------------------------------------------------------------
final class Ball {
  // Razina veličine loptice, 1 je najmanja loptica, 2 malo veća...
  // Kada se razbije loptica razine 2, nastaju dvije loptice razine 1.
  // Radijus ovisi o veličini loptice.
  // Predviđeno je da najveća razina loptica bude 6.
  int sizeLevel;
  float radius;
  // Središte loptice.
  float xCenter, yCenter;
  float xVelocity, yVelocity;
  
  // Boja loptice.
  BallColor ballColor;

  // Ako je split bilo što različito od -1, to označava da je loptica 
  // tek nastala nakon razdvajanja veće loptice. Varijablu koristimo
  // kako bi loptica mogla "poskočiti" nakon razdvajanja. Ako nije -1,
  // onda je njena vrijednost visina na kojoj je loptica od koje je
  // nastala pogođena.
  float split;
  
  // Atribut koji pamti udara li u određenom trenutku lopta igrača.
  boolean is_being_hit = false;
  
  // Atribut koji određuje koji je igrač udario lopticu prije no
  // što je nastala. 0 ako nije nijedan (za početne loptice).
  int hitByPlayer;

  // ----------------------------------------------------------
  // Metode
  // ----------------------------------------------------------
  Ball (float _xCenter, float _yCenter, int _sizeLevel, BallColor _ballColor) {
    sizeLevel = _sizeLevel;
    radius = sizeLevel * 10;
    xCenter = _xCenter; 
    yCenter = _yCenter;
    xVelocity = 1;
    yVelocity = 3;
    split = -1;
    hitByPlayer = 0;
    ballColor = _ballColor;
  }
  // Ovaj konstruktor koristimo kada stvaramo levele.
  Ball (float _xCenter, float _yCenter, int _sizeLevel, 
        float _xVelocity, float _yVelocity, 
        BallColor _ballColor) 
  {
    sizeLevel = _sizeLevel;
    radius = sizeLevel * 10;
    xCenter = _xCenter; 
    yCenter = _yCenter;
    xVelocity = _xVelocity;
    yVelocity = _yVelocity;
    split = -1;
    hitByPlayer = 0;
    ballColor = _ballColor;
  }
  // Ovaj konstruktor koristimo kada stvaramo loptice koje nastaju razdvajanjem.
  Ball (float _xCenter, float _yCenter, int _sizeLevel, 
        float _xVelocity, float _yVelocity, 
        float _split, int _hitByPlayer, BallColor _ballColor) 
  {
    sizeLevel = _sizeLevel;
    radius = sizeLevel * 10;
    xCenter = _xCenter; 
    yCenter = _yCenter;
    xVelocity = _xVelocity; 
    yVelocity = _yVelocity;
    split = _split;
    hitByPlayer = _hitByPlayer;
    ballColor = _ballColor;
  }
  
  // ----------------------------------------------------------
  // Iscrtavanje kugle na ekran.
  void draw() {
    update();
    image(ballImgs.get(ballColor), xCenter - radius, yCenter - radius, 2*radius, 2*radius);
  }
  
  // ----------------------------------------------------------
  // Ažuriranje pozicije kugle.
  void update() {
    // Pomakni kuglu.
    xCenter += 2*xVelocity; 
    yCenter += 2*yVelocity;
  
    // Varijabla top predstavlja gornji rub do kojeg loptica
    // skače. Njena vrijednost se postavlja na različit način
    // u ovisnosti o tome je li loptica tek nastala razdvajanjem
    // (tada ona poskoči).
    float top = 0;
    
    if (split == -1) // Loptica se ponaša normalno
      top = gameHeight - ballJumpHeight[sizeLevel];
    else { // Loptica je tek nastala, treba "poskočiti".
      // Ne smije otići izvan ekrana.
      if (split - splitBallJumpHeight[sizeLevel] > 0)
        top = split - splitBallJumpHeight[sizeLevel];
      // Loptica je završila s "poskokom", u nastavku se
      // treba ponašati normalno.
      if (yCenter >= split && yCenter >= gameHeight - ballJumpHeight[sizeLevel])
        split = -1;
    }
    
    // Odbijanje od rubova.
    if (xCenter + radius > (windowWidth + gameWidth)/2) { // Desni rub.
      xVelocity = xVelocity * -1;
      xCenter = (windowWidth + gameWidth)/2 - radius; // Reset za svaki slučaj.
    }

    if (xCenter - radius < (windowWidth - gameWidth)/2) { // Lijevi rub.
      xVelocity = xVelocity * -1;
      xCenter = (windowWidth - gameWidth)/2 + radius; // Reset za svaki slučaj.
    }

    if (yCenter + radius > gameHeight) { // Donji rub.
      yVelocity = yVelocity * -1;
      yCenter = gameHeight - radius; // Reset za svaki slučaj.
    }

    if (yCenter - radius < top) { // Gornji rub.
      yVelocity = yVelocity * -1;
      yCenter = top + radius; // Reset za svaki slučaj.
    }
  }
  
  // ----------------------------------------------------------
  // Metode za provjeru kolizije.
  boolean checkSpearCollision(float xSpear, float ySpear) {
    // Provjera je li bilo koja točka ispod glave koplja u radijusu
    // ove kugle.
    for (int i = (int)gameHeight; i >= ySpear; --i) {
      if (sq(xSpear - xCenter) + sq(i - yCenter) <= sq(radius))
        return true;
    }
    return false;
  }
  
  boolean checkPlayerCollision(float playerPosition) {
    // Provjera je li bilo koja točka unutar pravokutnika veličine
    // slike lika. Ovaj -5 je mala korekcija jer lik nije baš "pravokutnik".
    int wHalf = (int)(playerImgWidth / 2) - 5;
    int h = (int)playerImgHeight - 5;
    for (int i = (int)playerPosition - wHalf; i <= playerPosition + wHalf; ++i)
      for (int j = (int)gameHeight; j >= gameHeight - h; --j)
        if (sq(i - xCenter) + sq(j - yCenter) <= sq(radius))
          return true;
    return false;
  }
}
