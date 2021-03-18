// Klasa koja predstavlja loptice. //<>//
class Ball {
  // Razina veličine loptice, 1 je najmanja loptica, 2 malo veća...
  // Kada se razbije loptica razine 2, nastaju dvije loptice razine 1.
  // Radijus ovisi o veličini loptice.
  // Predviđeno je da najveća razina loptica bude 6.
  int sizeLevel;
  float radius;
  // Središte loptice.
  float xCenter, yCenter;
  float xVelocity, yVelocity;

  // Ako je split bilo što različito od gameHeight,
  // to označava da je loptica tek nastala.
  float split;
  
  // Atribut koji pamti udara li u određenom trenutku lopta igrača.
  boolean is_being_hit = false;
  
  // Atribut koji će pamtiti koje razine je bila 'parent' loptica (potrebno za računanje bodova).
  int origin;

  Ball (float _xCenter, float _yCenter, int _sizeLevel, int _origin) {
    sizeLevel = _sizeLevel;
    origin = _origin;
    radius = sizeLevel * 10;
    xCenter = _xCenter; 
    yCenter = _yCenter;
    xVelocity = 1;
    yVelocity = 3;
    split = gameHeight;
  }

  Ball (float _xCenter, float _yCenter, int _sizeLevel, float _xVelocity, float _yVelocity, float _split, int _origin) {
    sizeLevel = _sizeLevel;
    origin = _origin;
    radius = sizeLevel * 10;
    xCenter = _xCenter; 
    yCenter = _yCenter;
    xVelocity = _xVelocity; 
    yVelocity = _yVelocity;
    split = _split;
  }
  // Ažuriranje pozicije kugle.
  void update() {
    // Pomakni kuglu.
    xCenter += xVelocity; 
    yCenter += yVelocity;

    float top;
    if (sizeLevel >= 6) // Loptice levela 6 i veće su jednake visine.
      top = (float)1/7 * gameHeight - 50;
    else
      top = (float)(7 - sizeLevel)/7 * gameHeight - 50;

    // Loptica se nastavlja ponašati normalno.
    if (split != gameHeight && yCenter + radius > top && yCenter + radius > split)
      split = gameHeight;
    // Loptica je tek nastala, može ići više gore nego inače.
    else if (split != gameHeight)
      top = split - (float)(7 - sizeLevel)/7 * gameHeight - 50;
    // TODO: Računati top na neki drugi način, ovo je dosta loše. Loptica
    // bi trebala poskočiti kada se razbije.

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

  void draw() {
    fill(255, 0, 0);
    update();
    circle(xCenter, yCenter, sizeLevel * 10);
    fill(255);
  }

  boolean checkSpearCollision(float xSpear, float ySpear) {
    // Provjera je li bilo koja točka ispod glave koplja u radijusu
    // ove kugle.
    for (int i = (int)gameHeight; i >= ySpear; --i) {
      if (sq(xSpear - xCenter) + sq(i - yCenter) <= sq(radius))
        return true;
    }
    return false;
  }
  
  // TODO: Prepraviti funkciju kada se ubaci prava slika.
  boolean checkPlayerCollision(float playerPosition) {
    // Provjera je li bilo koja točka unutar igračevog pravokutnika u
    // radijusu kugle. Igrač je pravokutnik 25x50.
    for (int i = (int)playerPosition - 12; i <= playerPosition + 12; ++i)
      for (int j = (int)gameHeight; j >= gameHeight - 50; --j)
        if (sq(i - xCenter) + sq(j - yCenter) <= sq(radius))
          return true;
    return false;
  }
}
