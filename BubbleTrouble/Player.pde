// Klasa koja predstavlja igrača, uključujući koplje.
class Player {
  // Pozicija igrača je određena x-koordinatom sredine sličice.
  float position;
  // Broj preostalih života.
  int lives = 4;

  // Pozicija glave koplja.
  float xSpear, ySpear;
  // Koplje je aktivno/trenutno ide prema gore.
  boolean spearActive = false, spearUp = false;


  Player(float _position) {
    position = _position;
    ySpear = gameHeight; // Na dnu prozora s igrom.
  }

  // Iscrtavanje igrača na ekran. Za sada se samo crta kao 25x50 pravokutnik.
  void draw() {
    fill(0);

    if (isLeft) position = position - 2;
    if (isRight) position = position + 2;
    if (isSpace && !spearActive)
      activateSpear();
    // Position je sredina sličice (pravokutnika).
    rect(position - 12.5, gameHeight - 50, 25, 50);
    // Nacrtaj koplje (ako je aktivno).
    if (spearActive)
      rect(xSpear - 1, ySpear, 2, gameHeight - ySpear);

    fill(255);
  }

  void move(float x) {
    position += x;
  }

  void resetPosition() {
    position = windowWidth/2 - 25;
    // TODO: Promijeniti kada igraju dva igrača.
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
      if (ySpear >= gameHeight)
        spearActive = false;
    }
  }

  void activateSpear() {
    xSpear = position; // Koplje počinje na trenutnoj poziciji igrača.
    spearActive = true;
    spearUp = true;
  }

  void resetSpear() {
    spearActive = false;
    ySpear = gameHeight;
  }

  boolean isSpearActive() { 
    return spearActive;
  }
}
