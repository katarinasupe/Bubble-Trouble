// Veličina okvira za igru. //<>//
final float gameWidth = 1024, gameHeight = 576;
// Veličina prozora.
final float windowWidth = 1280, windowHeight = 720; // Ako se mijenja, treba promijeniti size u setup().
// Postavljamo broj igrača i kreiramo listu u koju ćemo kasnije igrače pohranjivati.
int quantity = 2;
ArrayList<Player> players = new ArrayList<Player>();
// Lista u kojoj se čuvaju sve lopte trenutno na ekranu.
ArrayList<Ball> balls = new ArrayList<Ball>();

boolean isLeft, isRight, isSpace, isA, isD, isS;
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
  balls.clear();
  balls.add(new Ball(windowWidth/2, gameHeight/2, 4));
  // Ovisno o postavljenom broju igrača, popunjavamo listu i podešavamo početne pozicije
  for (int i = 0; i < quantity; i++)
    players.add(new Player((i+1)*windowWidth/(quantity+1)-25, i+1));
  ellipseMode(RADIUS); // Crtanje kružnica kao (srediste.x, srediste.y, radijus).
}

void draw() {
  if (state == State.MAINMENU) {
    // TODO: Main menu.
  } else if (state == State.SETTINGS) {
    // TODO: Settings.
  } else if (state == State.GAME) {
    // Provjeri kolizije.
    for (Player player : players) {
      if (player.spearActive)
        ballSpearCollision();
    }
    
    ballPlayerCollision();
    
    // Ažuriraj kugle i igrače.
    for (Ball ball : balls)
      ball.update();
    for (Player player: players)
      player.update();
    
    // Ponovno iscrtaj pozadinu -- ovo možda može i prije ovih grananja ovisno o state.
    background(0);
    rect((windowWidth - gameWidth)/2, 0, gameWidth, gameHeight);
    
    // Ispis preostalih života, ovo će vjerojatno biti sličice kasnije.
    fill(255);
    textSize(30);
    int j = 0;
    for (Player player : players) {
      text("Player " + (j+1) + ":  " + player.lives, 200*j, windowHeight-20 );
      j++;
    }
  
    // Nacrtaj igrače i lopte.
    for (Player player: players)
      player.draw();
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
  // Standardne left-right tipke za prvog igrača.
  switch (k) {
  case LEFT:
    isLeft = b;
    return;

  case RIGHT:
    isRight = b;
    return;
  }

}

void setMove(char k, boolean b) {
  switch (k) {
  // Tipka za koplje prvog igrača.
  case ' ':
    isSpace = b;
    return;
  
  // Sve tipke za drugog igrača: a-lijevo, d-desno, s-koplje
  case 'a':
    isA = b;
    return;

  case 'd':
    isD = b;
    return;
  
  case 's':
    isS = b;
    return;
  }
}

// Funkcija za detekciju kolizije lopti i koplja.
void ballSpearCollision() {
  // Za svakog igrača (prva for petlja) i svaku loptu (druga for petlja)
  // gledamo dolazi li do kolizije i potom postupamo prikladno.
  for (Player player : players) {
    for (int i = 0; i < balls.size(); ++i) {
      if (balls.get(i).checkSpearCollision(player.xSpear, player.ySpear)) {
        player.resetSpear();
        if (balls.get(i).sizeLevel > 1) {
          balls.add(new Ball(balls.get(i).xCenter, balls.get(i).yCenter, balls.get(i).sizeLevel-1, 1, -3, balls.get(i).yCenter));
          balls.add(new Ball(balls.get(i).xCenter, balls.get(i).yCenter, balls.get(i).sizeLevel-1, -1, -3, balls.get(i).yCenter));
        }
        balls.remove(i);
        return;
      }
    }
  }
}

// Funkcija za detekciju kolizije lopti i igrača.
void ballPlayerCollision() {
  // Također prolazimo po svim igračima i loptama i provjeravamo dolazi li do kolizije.
  for (Player player : players) {
    for (int i = 0; i < balls.size(); ++i) {
      Ball current = balls.get(i);
      if (current.checkPlayerCollision(player.position)) {
        if (!current.is_being_hit) {
          --player.lives;
          // Ako je kolizija tek počela, postavljamo atribut na true.
          // Ovime izbjegavao da se odjednom oduzme nekoliko života umjesto jednog.
          current.is_being_hit = true;
        }
        // Iako je samo jedan igrač pogođen, pozicije se resetiraju za oba igrača
        for (Player player_: players)
          player_.resetPosition();
        // Ponovno postavljamo kugle
        balls.clear();
        balls.add(new Ball(windowWidth/2, gameHeight/2, 6));

        // TODO: Game over.
        //       Ali, ako jedan igrač izgubi, drugi još ostaje!
        // if (player.lives <= 0) setup();
        
      }
      else current.is_being_hit = false; // Ako kolizije više nema, postavljamo atribut na false.
    }
  }
}
