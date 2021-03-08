// Veličina okvira za igru. //<>//
final float gameWidth = 1024, gameHeight = 576;
// Veličina prozora.
final float windowWidth = 1280, windowHeight = 720; // Ako se mijenja, treba promijeniti size u setup().
// Igrač se na početku nalazi na sredini ekrana.
// TODO: Prilagoditi za dva igrača.
Player player1 = new Player(windowWidth/2 - 25);
// Lista u kojoj se čuvaju sve lopte trenutno na ekranu.
ArrayList<Ball> balls = new ArrayList<Ball>();

boolean isLeft, isRight, isSpace;
// Moguća stanja programa. Ovisno o varijabli state, u draw()
// se iscrtavaju različiti prozori.
enum State {
  MAINMENU, 
    SETTINGS, 
    GAME
}
State state = State.GAME; // Treba biti MAINMENU kad se napravi.

void setup() {
  size(1280, 720);
  balls.add(new Ball(windowWidth/2, gameHeight/2, 6));
  ellipseMode(RADIUS); // Crtanje kružnica kao (srediste.x, srediste.y, radijus).
}

void draw() {
  if (state == State.MAINMENU) {
    // TODO: Main menu.
  } else if (state == State.SETTINGS) {
    // TODO: Settings.
  } else if (state == State.GAME) {
    // Provjeri kolizije.
    if (player1.spearActive)
      ballSpearCollision();
    ballPlayerCollision();
    
    // Ažuriraj kugle i igrače.
    for (Ball ball : balls)
      ball.update();
    player1.update();
    
    // Ponovno iscrtaj pozadinu -- ovo možda može i prije ovih grananja ovisno o state.
    background(0);
    rect((windowWidth - gameWidth)/2, 0, gameWidth, gameHeight);
    
    // Ispis preostalih života, ovo će vjerojatno biti sličice kasnije.
    fill(255);
    textSize(30);
    text("Lives: " + player1.lives, 0, windowHeight);
  
    // Nacrtaj igrača i lopte.
    player1.draw();
    for (Ball ball : balls)
      ball.draw();
  }
}

// Funkcije za pomicanje igrača. Malo zakomplicirano zbog toga da
// pomicanje izgleda više "glatko".
void keyPressed() {
  if (key == CODED)
    setMove(keyCode, true);
  else
    setMove(key, true);
}

void keyReleased() {
  if (key == CODED)
    setMove(keyCode, false);
  else
    setMove(key, false);
}

void setMove(int k, boolean b) {
  switch (k) {
  case LEFT:
    isLeft = b;
    return;

  case RIGHT:
    isRight = b;
    return;
  }

  // TODO: Dodati za drugog igrača.
}

void setMove(char k, boolean b) {
  switch (k) {
  case ' ':
    isSpace = b;
    return;
  }
}

// Funkcija za detekciju kolizije lopti i koplja.
void ballSpearCollision() {
  for (int i = 0; i < balls.size(); ++i) {
    if (balls.get(i).checkSpearCollision(player1.xSpear, player1.ySpear)) {
      player1.resetSpear();
      if (balls.get(i).sizeLevel > 1) {
        balls.add(new Ball(balls.get(i).xCenter, balls.get(i).yCenter, balls.get(i).sizeLevel-1, 1, -3, balls.get(i).yCenter));
        balls.add(new Ball(balls.get(i).xCenter, balls.get(i).yCenter, balls.get(i).sizeLevel-1, -1, -3, balls.get(i).yCenter));
      }
      balls.remove(i);
      return;
    }
  }
}

// Funkcija za detekciju kolizije lopti i igrača.
void ballPlayerCollision() {
  for (int i = 0; i < balls.size(); ++i) {
    if (balls.get(i).checkPlayerCollision(player1.position)) {
      --player1.lives;
      player1.resetPosition();
      // TODO: Resetirati kugle?

      // TODO: Game over.
      /*if (lives <= 0)*/
    }
  }
}
