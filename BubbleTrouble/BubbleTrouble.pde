// Veličina okvira za igru. //<>//
final float gameWidth = 1024, gameHeight = 576;
// Veličina prozora.
final float windowWidth = 1280, windowHeight = 720; // Ako se mijenja, treba promijeniti size u setup().
// Postavljamo broj igrača i kreiramo listu u koju ćemo kasnije igrače pohranjivati.
int quantity = 1;
ArrayList<Player> players = new ArrayList<Player>();
// Lista u kojoj se čuvaju sve lopte trenutno na ekranu.
ArrayList<Ball> balls = new ArrayList<Ball>();

//slike u MAINMENU
PImage character, bubbleTrouble, redBall, torch;
PFont menuFont;
PFont gameFont;

boolean isLeft, isRight, isSpace, isA, isD, isS, isUp, isDown, isEnter;
final int ENTER_CODE = 10; //moze biti problema s ovim

// Moguća stanja programa. Ovisno o varijabli state, u draw()
// se iscrtavaju različiti prozori.
enum State {
    MAINMENU, 
    INSTRUCTIONS, 
    GAME
}
// Na početku igre vidimo stanje MAINMENU
State state = State.MAINMENU; 

//Mogući odabiri u meniju  
enum MenuPick {
  ONEPLAYER,
  TWOPLAYERS,
  CONTROLS,
  QUIT
}
//Na početku je odabrano polje "1 PLAYER"
MenuPick menuPick = MenuPick.ONEPLAYER;

void setup() {
  size(1280, 720);
  balls.clear();
  balls.add(new Ball(windowWidth/2, gameHeight/2, 4));
  // Ovisno o postavljenom broju igrača, popunjavamo listu i podešavamo početne pozicije
 // for (int i = 0; i < quantity; i++)
 //   players.add(new Player((i+1)*windowWidth/(quantity+1)-25, i+1));
 //   ellipseMode(RADIUS); // Crtanje kružnica kao (srediste.x, srediste.y, radijus).
  
  //učitavanje slika za MAINMENU
  character = loadImage("character.png");
  bubbleTrouble = loadImage("bubbleTrouble.png");
  redBall = loadImage("redBall.png");
  torch = loadImage("torch.png");
  
  //učitavanje fonta za MAINMENU
  menuFont = loadFont("GoudyStout-28.vlw");
  
  //učitavanje fonta za GAME
  gameFont = loadFont("GoudyStout-16.vlw");
}

void createPlayers() {
   // Ovisno o postavljenom broju igrača, popunjavamo listu i podešavamo početne pozicije
  for (int i = 0; i < quantity; i++)
    players.add(new Player((i+1)*windowWidth/(quantity+1)-25, i+1));
    ellipseMode(RADIUS); // Crtanje kružnica kao (srediste.x, srediste.y, radijus).
}

void draw() {
  // Trenutno bi trebao raditi ENTER za ulazak u igru s jednim igračem
  // TODO: Mijenjanje odabira polja s UP i DOWN (mijenjanje boja pravokutnika ili pomicanje baklji)
  // te s obzirom na to mijenjanje menuPick i quantity
  if (state == State.MAINMENU) {   
    //pushStyle() i popStyle() za očuvanje trenutnog stila i naknadno vraćanje istog
    pushStyle();
    //pozadina - neka siva boja
    background(190, 190, 190);
    
    //crtanje vodoravnih i vertikalnih linija na pozadini (cigle) - treba još uljepšati
    int horizontalLines = 9;
    int verticalLines = 8;
    stroke(226, 226, 226);
    for (int i = 1; i < horizontalLines; i++) {
      line(0, i*windowHeight/horizontalLines, windowWidth, i*windowHeight/horizontalLines);
    }
    for (int i = 1; i < verticalLines; i++) {
      line(i*windowWidth/verticalLines, 0, i * windowWidth/verticalLines, windowHeight);
    }
       
    //dodavanje lika, crvene kugle i baklji
    imageMode(CENTER);
    image(character, 2*windowWidth/3, windowHeight/2);
    image(redBall, windowWidth/4, windowHeight/4);
    image(torch, windowWidth/11 , windowHeight/2);
    image(torch, windowWidth/2.46, windowHeight/2);
  
    //dodavanje i rotacija slike bubbleTrouble (tekst)
    pushMatrix();
    rotate(radians(-15));
    image(bubbleTrouble, windowWidth/5, windowHeight/3);
    popMatrix();
    
    //----MENU----
    //vanjski žuti pravokutnik
    rectMode(RADIUS);
    stroke(183, 180, 16);
    strokeWeight(4);
    fill(255, 252, 0);
    float rectX = windowWidth/4;
    float rectY = 2*windowHeight/3 + 20;
    rect(rectX, rectY, windowWidth/8, windowHeight/4 - 15);
    rectMode(CENTER); 
    //ukupna visina pravokutnika koji sadržava polja za odabir
    float totalHeight = windowHeight/2 - 50;
    //postoje 4 polja za odabir, svako visine fieldHeight
    float fieldHeight = totalHeight/4;
    //i će određivati y-koordinatu centra svakog polja za odabir
    float i = fieldHeight/2;
    while (i < totalHeight) {
      //crtanje crvenih polja za odabir (pravokutnika)
      fill(224, 0, 0);
      rect(rectX, rectY - totalHeight/2 + i, rectX - 20, fieldHeight);
      //pisanje teksta u odgovarajuće pravokutnike
      fill(255, 245, 0);
      textAlign(CENTER, CENTER);
      textFont(menuFont);
      if(i < fieldHeight)
        text("1 PLAYER", rectX, rectY - totalHeight/2 + i);
      else if(i < fieldHeight*2)
        text("2 PLAYERS", rectX, rectY - totalHeight/2 + i);
      else if(i < fieldHeight*3)
        text("CONTROLS", rectX, rectY - totalHeight/2 + i);
      else
        text("QUIT", rectX, rectY - totalHeight/2 + i);
      //pomak na iduće polje za odabir
      i += fieldHeight;
    }
    popStyle();
    
    if (isEnter) {
      //print("enter");
      if (menuPick == MenuPick.ONEPLAYER){
        quantity = 1;
        createPlayers();
        state = State.GAME;
      }
      else if (menuPick == MenuPick.TWOPLAYERS){
        quantity = 2;
        createPlayers();
        state = State.GAME;
      }
      else if (menuPick == MenuPick.CONTROLS) state = State.INSTRUCTIONS;
      else exit();
    }
    
  } else if (state == State.INSTRUCTIONS) {
    // TODO: Instructions.
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
    textFont(gameFont);
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
  else {
    if (keyCode == ENTER_CODE)
      setMove(keyCode, true);
    else
      setMove(key, true);
  }
}

void keyReleased() {
  if (key == CODED)
    setMove(keyCode, false);
  else {
    if (keyCode == ENTER_CODE)
      setMove(keyCode, false);
    else
      setMove(key, false);
  }
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
    
  // gore, dolje za pomicanje odabira u meniju te Enter (10) za odabir
  case UP:
    isUp = b;
    return;
  
  case DOWN:
    isDown = b;
    return;
    
  case 10:
    isEnter = b;
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
