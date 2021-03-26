import processing.sound.*; //<>//

// Veličina okvira za igru.
final float gameWidth = 1024, gameHeight = 576;
// Veličina prozora.
final float windowWidth = 1280, windowHeight = 720; // Ako se mijenja, treba promijeniti size u setup().
// Postavljamo broj igrača i kreiramo listu u koju ćemo kasnije igrače pohranjivati.
int quantity;
ArrayList<Player> players = new ArrayList<Player>();
// Lista u kojoj se čuvaju sve lopte trenutno na ekranu.
ArrayList<Ball> balls = new ArrayList<Ball>();
// Niz koji čuva supermoći trenutnog levela.
String[] superpowers;
// Varijabla koja pohranjuje istinu ako je igra gotova, inače laž
boolean is_game_over = false;
// Varijabla koja pamti je li u tijeku čekanje ponovnog početka igre.
boolean get_ready = false;
boolean new_points_added;
// Varijabla koja pamti na kojem je levelu igrač trenutno.
int current_level;
Level level;
// Varijable koja pamti je li završen level:
boolean level_done = false;
boolean game_completed = false, times_up = false, time_up_over = false;
// Varijabla u kojoj pohranjujemo mogući broj bodova.
int max_points;
// Varijable za pohranjivanje vremena (dovoljno je uzeti minute i sekunde):
int minutes, seconds, millis, delay_millisecs, getReady_millisecs, levelWon_millisecs, temp_millisecs, paused_millisecs, gameover_millisecs;
boolean timer = false;

// Slike u INTRO stanju
PImage introRedBall, arrow, redLayer, bubble, trouble;

// Slike u MAINMENU stanju
PImage bubbleTrouble, redBall, torch, fire, soundOnImg, soundOffImg, menuBackground, instructions, menuButton;
PImage onePlayerCharacter, twoPlayersCharacter, controlsCharacter, quitCharacter;
PImage bottomWall, topWall; // polovice zidova koje se pomiču

// Slike u GAME stanju
ArrayList<PImage> player1_images; //slike igrača
ArrayList<PImage> player2_images;
PImage player1_text, player2_text;
PImage spearImg; // Slika koplja.
//PImage levelBackground;  // Slika pozadine levela
PImage levelImg; // Slika broja levela.
PImage pauseImg; // Slika za 'pauza' gumb.
PImage restartImg; // Slika za restart gumb.
PImage thornsImg; // Slika bodlji na vrhu ekrana.
PImage menuBackgroundSmall; // Za pokrivanje koplja, crta se u draw() kad je state == GAME.

// Globalne varijable potrebne za pozicioniranje 'Bubble Trouble' teksta u INTRO stanju
float bubbleX, bubbleY, currentBubbleY, troubleX, troubleY, currentTroubleY;
boolean isBubblePlaced, isTroublePlaced, isGunPlaced, isBubbleGone, isTroubleGone;

// Početne vrijednosti vezane uz pomicanje zidova (transition)
float transitionFactor = 5; // Za koliko se piksela zid pomiče svaki frame
float bottomWallHeight = windowHeight/2 - transitionFactor;
float topWallHeight = transitionFactor;
float totalMoveCtr = 0; // Kontrola izlaženja van ekrana, kada pomicanje više nije potrebno

// Fontovi
PFont menuFont;
PFont gameFont;

// Globalne varijable potrebne za provjeru pritiska određene tipke na tipkovnici
boolean isLeft, isRight, isSpace, isA, isD, isS, isUp, isDown, isEnter;
final int ENTER_CODE = 10; // Tipka 'Enter' je specijalna tipka

// Moguća stanja programa. Ovisno o varijabli state, u draw()
// se iscrtavaju različiti prozori.
enum State {
    INTRO,
    MAINMENU, 
    INSTRUCTIONS, 
    GAME,
    PAUSE,
    RESULTS
}
// Na početku igre vidimo stanje INTRO
State state = State.INTRO; 

// Mogući odabiri u meniju  
enum MenuPick {
  ONEPLAYER,
  TWOPLAYERS,
  CONTROLS,
  QUIT
}
// Na početku je odabrano polje "1 PLAYER"
MenuPick menuPick = MenuPick.ONEPLAYER;

// Zvukovi koji se pojavljuju u igri
SoundFile onePlayerSound, twoPlayersSound, controlsSound;
SoundFile introSong;
SoundFile shootingSound;
SoundFile collisionSound;
SoundFile switchSound;
SoundFile punchSound;
SoundFile levelDoneSound;
String path; // Putanja koja će se koristiti za pronalaženje putanje zvukova

// Funkcija koja vraća zvuk shootingSound
SoundFile getShootingSound(){
    return shootingSound;
}

boolean soundOn = true; // Na početku je zvuk uključen
// Funkcija koja vraća vrijednost boolean varijable soundOn
boolean getSound() {
  return soundOn;
}

boolean lostLife = false;

// Supermoći (štit, život)
String activeSuperpower = "";
PImage activeSuperpowerImg;
float xSuperpowerPosition, ySuperpowerPosition;
int superpowerHeight = 25, superpowerWidth = 25;
int superpower_millisecs;

void setup() {
  
  size(1280, 720);
  current_level = 1;
  level = new Level(1);
  is_game_over = false;
  game_completed  = false;
  level_done = false;
  lostLife = true;
  balls.clear();
  balls = (ArrayList<Ball>)level.balls.clone();
  superpowers = level.superpowers;
  // Pamtimo vrijeme početka radi kasnijeg računanja bodova:
  minutes = minute();
  seconds = second();
  millis = millis();
  paused_millisecs = 0;
  timer = false; //ovo isto treba prebaciti u startgame
  pause_game();
  
  // ----------------------------------------------------------
  // ---------------------UČITAVANJE SLIKA---------------------
  // ----------------------------------------------------------
  
  // -------------Učitavanje slika za INTRO stanje-------------
  introRedBall = loadImage("introRedBall.png");
  redLayer = loadImage("redLayer.png");
  arrow = loadImage("arrow.png");
  bubble = loadImage("bubble.png");
  trouble = loadImage("trouble.png");
  
  // -------------Učitavanje slika za MAINMENU stanje-------------
  onePlayerCharacter = loadImage("onePlayerCharacter.png");
  twoPlayersCharacter = loadImage("twoPlayersCharacter.png");
  controlsCharacter = loadImage("controlsCharacter.png"); 
  quitCharacter = loadImage("quitCharacter.png"); 
  bubbleTrouble = loadImage("bubbleTrouble.png");
  redBall = loadImage("redBall.png");
  torch = loadImage("torch.png");
  soundOnImg = loadImage("soundOn.png");
  soundOffImg = loadImage("soundOff.png");
  menuBackground = loadImage("menuBackground2.png"); // Napomena: Koristi se i u crtanju igre kad je state == GAME.
  fire = loadImage("fire.png");
  
  // -------------Učitavanje slika za INSTRUCTIONS stanje-------------
  instructions = loadImage("instructions.png");
  menuButton = loadImage("menuButton.png");
  

  // -------------Učitavanje slika za GAME stanje-------------
  pauseImg = loadImage("pause.png");
  restartImg = loadImage("restart.png");
  // -----------------------------------------------------------
  //slike igrača
  player1_images = new ArrayList<PImage>(); 
  player1_images.add(loadImage("player1_back.png"));//0
  player1_images.add(loadImage("player1_left.png"));//1
  player1_images.add(loadImage("player1_right.png"));//2
  player1_images.add(loadImage("player1_back_shield.png"));//3
  player1_images.add(loadImage("player1_left_shield.png"));//4
  player1_images.add(loadImage("player1_right_shield.png"));//5
  if(quantity == 2) {
    player2_images = new ArrayList<PImage>();
    player2_images.add(loadImage("player2_back.png"));//0
    player2_images.add(loadImage("player2_left.png"));//1
    player2_images.add(loadImage("player2_right.png"));//2
    player2_images.add(loadImage("player2_back_shield.png"));//3
    player2_images.add(loadImage("player2_left_shield.png"));//4
    player2_images.add(loadImage("player2_right_shield.png"));//5 
  }
  // ------------------------------------------------------------
  // Učitavanje slike bodlji (trebala bi već biti širine 1024, kao i gameHeight).
  // Treba resize ako se gameHeight promijeni.
  thornsImg = loadImage("thorns.png");  
  // ------------------------------------------------------------
  // Učitavanje slike koplja.
  spearImg = loadImage("spear.png");
  // Računanje visine koplja tako da slika zadrži aspect
  // ratio prema varijabli spearImgWidth zadanoj u Player.pde.
  spearImgHeight = ((float)spearImg.height / spearImg.width) * spearImgWidth;
  // Odmah smanji sliku.
  spearImg.resize((int)spearImgWidth, (int)spearImgHeight);
  
  // ------------------------------------------------------------
  // Učitavanje "odrezane" pozadine menija tako da pokrije koplje koje se inače
  // iscrtava preko pozadine i izlazi iz okvira igre.
  menuBackgroundSmall = loadImage("menuBackground2_gameHeight.png");
  
  // ------------------------------------------------------------
  // Učitavanje slika loptica.
  ballImgs = new HashMap<BallColor, PImage>();
  ballImgs.put(BallColor.RED,    loadImage("redBall.png"));
  ballImgs.put(BallColor.BLUE,   loadImage("ballBlue.png"));
  ballImgs.put(BallColor.GREEN,  loadImage("ballGreen.png"));
  ballImgs.put(BallColor.ORANGE, loadImage("ballOrange.png"));
  ballImgs.put(BallColor.PURPLE, loadImage("ballPurple.png"));
  ballImgs.put(BallColor.YELLOW, loadImage("ballYellow.png"));
  
  // -------------Učitavanje slika za RESULTS stanje-------------
  player1_text = loadImage("player1_text.png");
  player2_text = loadImage("player2_text.png");  
  
  // -------------Učitavanje slika za tranziciju-------------
  topWall = loadImage("topWall.png");
  bottomWall = loadImage("bottomWall.png");
  
  // KORISTI LI SE OVO?
  //levelImg = loadImage("level1.png");
  //levelBackground = loadImage("level1_background.png");
  
  // ------------------------------------------------------------
  // ---------------------UČITAVANJE FONTOVA---------------------
  // ------------------------------------------------------------
  //učitavanje fonta za MAINMENU
  menuFont = loadFont("GoudyStout-28.vlw");  
  //učitavanje fonta za GAME
  gameFont = loadFont("GoudyStout-23.vlw");
  
  // ------------------------------------------------------------
  // ---------------------UČITAVANJE ZVUKOVA---------------------
  // ------------------------------------------------------------
  path = sketchPath("");
  path = path + "\\sounds\\";
  introSong = new SoundFile(this, path + "intro.mp3");
  shootingSound = new SoundFile(this, path + "shooting.mp3");
  collisionSound = new SoundFile(this, path + "collision.mp3");
  switchSound = new SoundFile(this, path + "switch.mp3");
  punchSound = new SoundFile(this, path + "punch.mp3");
  levelDoneSound = new SoundFile(this, path + "end_of_level.mp3");
  onePlayerSound = new SoundFile(this, path + "onePlayer.mp3");
  twoPlayersSound = new SoundFile(this, path + "twoPlayers1.mp3");
  controlsSound = new SoundFile(this, path + "controls1.mp3");
  
  // Želimo da intro svira samo u INTRO state-u
  if(state == State.INTRO) {
    introSong.loop();
  }
  
  setIntroCoordinates(); // Postavljamo željene koordinate animiranog teksta u INTRO
  
  // ------------------------------------------------------------
  // Računanje visina do koje loptice skaču. Varijabla i je u ovom
  // slučaju sizeLevel. ballJumpHeight[0] ne koristimo.
  ballJumpHeight = new float[7];
  for (int i = 0; i < 7; ++i)
    ballJumpHeight[i] = (float)i / 7 * gameHeight + 50;
  splitBallJumpHeight = new float[7];
  for (int i = 0; i < 7; ++i)
    // "Eksperimentalno" odabrana formula.
    splitBallJumpHeight[i] = (float)sq(gameHeight)/(800 + i*500);
}

// Funkcija koja postavlja početne i krajnje koordinate teksta u INTRO stanju
void setIntroCoordinates() {
  bubbleX = 2*windowWidth/3;
  bubbleY = windowHeight/2;
  currentBubbleY = windowHeight + bubble.height/2;
  troubleX = 2*windowWidth/3;
  troubleY = windowHeight/2 + bubble.height;
  currentTroubleY = windowHeight + trouble.height/2;
  isBubblePlaced = false;
  isTroublePlaced = false;
  isGunPlaced = false;
  isBubbleGone = false;
  isTroubleGone = false;
}

// Funkcija koja ovisno o postavljenom broju igrača, popunjava listu i podešava početne pozicije igrača
void createPlayers() {
  players.clear();
  for (int i = 0; i < quantity; i++)
    players.add(new Player((i+1)*windowWidth/(quantity+1), i+1));
    ellipseMode(RADIUS); // Crtanje kružnica kao (srediste.x, srediste.y, radijus).
}

// Pomoćna funkcija za pisanje poruka tokom igre
void write_dummy_text(String _text) {
  textAlign(CENTER, CENTER);
  stroke(183, 180, 16);
  strokeWeight(4);
  fill(255, 245, 0);
  int _width = 450;
  float rectX = windowWidth/2;
  float rectY = windowHeight/2;
  rect(rectX-_width/2, rectY-40, _width, 80);
  fill(224, 0, 0);
  rectX = windowWidth/2-_width/2+8;
  rectY = windowHeight/2-32;
  rect(rectX, rectY, _width-16, 64);
  fill(255, 245, 0);
  textSize(25);
  text(_text, windowWidth/2, windowHeight/2);
  fill(255);
  stroke(0);
  strokeWeight(1);
}

// Funkcija kojom ponovno postavljamo brzine loptica
void restart_the_balls() {
  for (Ball ball : balls) {
    ball.xVelocity = level.ballXVelocity;
    ball.yVelocity = level.ballYVelocity;
  }
}

// Funkcija za crtanje zida koji se pomiče pri prijelazu s glavnog izbornika u igru
void drawTransition() {
  if (topWall.height - totalMoveCtr > 0) {
    topWallHeight -= transitionFactor;
    bottomWallHeight += transitionFactor;
    image(topWall, 0, topWallHeight);
    image(bottomWall, 0, bottomWallHeight);
    totalMoveCtr += transitionFactor;
  }
}

// Funkcija za resetiranje tranzicije
void resetTransition() {
  bottomWallHeight = windowHeight/2 - transitionFactor;
  topWallHeight = transitionFactor;
  totalMoveCtr = 0;  
}

// Funkcija za pokretanje nove igre ovisno o odabranom broju igrača.
void play_game(int _quantity){  
    quantity = _quantity;
    createPlayers();
    state = State.GAME;
    setup();
}

// Vraćanje u glavni izbornik tako da odabir bude defaultan
void resetGame() {
  state = State.MAINMENU;
  menuPick = MenuPick.ONEPLAYER;
  resetTransition(); // tako da se ispravno nacrta iduća tranzicija u MAINMENU
  if(soundOn) 
    switchSound.play(); // tranzicija (zidovi)
  unsetMoves();
}

// Pomoćna funkcija koja provjerava nalazi li se miš na '1 PLAYER' MENU izboru.
boolean overOnePlayer(int x, int y){
  if(x >= (windowWidth/4 - 150) && x <= (windowWidth/4 - 150 + windowWidth/4 - 20) && 
         y >= (2*windowHeight/3 + 20 - (windowHeight/2 - 50)/2) && y <= (2*windowHeight/3 + 20 - (windowHeight/2 - 50)/2 + (windowHeight/2 - 50)/4))
    return true;
  return false;         
}

// Pomoćna funkcija koja provjerava nalazi li se miš na '2 PLAYERS' MENU izboru.
boolean overTwoPlayers(int x, int y){
  if(x >= (windowWidth/4 - 150) && x <= (windowWidth/4 - 150 + windowWidth/4 - 20) && 
         y >= (2*windowHeight/3 + 20 - (windowHeight/2 - 50)/4) && y <= (2*windowHeight/3 + 20 - (windowHeight/2 - 50)/4 + (windowHeight/2 - 50)/4))
    return true;
  return false;
}

// Pomoćna funkcija koja provjerava nalazi li se miš na 'CONTROLS' MENU izboru.
boolean overControls(int x, int y){
  if(x >= (windowWidth/4 - 150) && x <= (windowWidth/4 - 150 + windowWidth/4 - 20) && 
      y >= (2*windowHeight/3 + 20) && y <= (2*windowHeight/3 + 20 + (windowHeight/2 - 50)/4))
    return true;
  return false;
}

// Pomoćna funkcija koja provjerava nalazi li se miš na 'QUIT' MENU izboru.
boolean overQuit(int x, int y){
  if(x >= (windowWidth/4 - 150) && x <= (windowWidth/4 - 150 + windowWidth/4 - 20) && 
          y >= (2*windowHeight/3 + 20 + (windowHeight/2 - 50)/4) && y <= (2*windowHeight/3 + 20 + (windowHeight/2 - 50)/4 + (windowHeight/2 - 50)/4))
    return true;
  return false;
}

// Funkcija ažurira (ako je) na kojem je od 4 MENU izbora miš trenutno.
// Inače ostaje na izboru odabranom strelicama.
void update(int x, int y){
  if(overOnePlayer(x, y)){
    menuPick = MenuPick.ONEPLAYER;
  }
  else if(overTwoPlayers(x, y)){
    menuPick = MenuPick.TWOPLAYERS;
  }
  else if(overControls(x, y)){
    menuPick = MenuPick.CONTROLS;
  }
  else if(overQuit(x, y)){
    menuPick = MenuPick.QUIT;
  }
}

void draw() {
  // ------------------------------------------------------------
  // INTRO
  // ------------------------------------------------------------
  if (state == State.INTRO) {
    // pushStyle() i popStyle() za očuvanje trenutnog stila i naknadno vraćanje istog
    pushStyle();
    background(menuBackground); // Postavi pozadinu
    imageMode(CENTER);
    image(introRedBall, windowWidth/2, windowHeight/2); // Postavi crvenu kuglu
    
    //--------Animacija teksta BUBBLE--------
    // Sve dok ne dođe do željene pozicije i dok lik nema pištolj, pomiči se gore
    if (currentBubbleY > bubbleY && !isGunPlaced) {
      currentBubbleY -= 5; // Pomak od 5px u svakom frameu
      image(bubble, bubbleX, currentBubbleY);
    }
    // Inače, ako je tekst došao na željeno mjesto i lik nema pištolj, neka ostane gdje je i postavi isBubblePlaced na true
    else if (currentBubbleY <= bubbleY && !isGunPlaced){ // završna pozicija teksta BUBBLE
      image(bubble, bubbleX, bubbleY);
      isBubblePlaced = true;
    }
    // Inače ako lik ima pištolj
    else if (isGunPlaced) {
      // Sve dok tekst bubble nije izašao van prozora, nek se pomiče dolje
      if (currentBubbleY <= windowHeight + bubble.height/2) {
        currentBubbleY += 5; // Pomak od 5px u svakom frameu
        image(bubble, bubbleX, currentBubbleY);
      }
      else { // Kad izađe van prozora, nestao je pa postavljamo isBubbleGone na true
        image(bubble, bubbleX, windowHeight + bubble.height/2);
        isBubbleGone = true;
      }
    }
      
    //--------Animacija teksta TROUBLE--------
    // Nakon što je bubble postavljen, sve dok ne dođe do željene pozicije i dok lik nema pištolj, pomiči se gore
    if (isBubblePlaced && currentTroubleY > troubleY && !isGunPlaced) {
       currentTroubleY -= 5; // Pomak od 5px u svakom frameu
      image(trouble, troubleX, currentTroubleY);
    }
    // Inače, ako je tekst došao na željeno mjesto i bubble je na mjestu i još nije nestao, neka ostane gdje je i postavi isTroublePlaced na true
    else if (isBubblePlaced && currentTroubleY <= troubleY && !isBubbleGone) { // Završna pozicija teksta TROUBLE
      image(trouble, 2*windowWidth/3, windowHeight/2 + bubble.height);
      isTroublePlaced = true;
    } 
    // Inače ako lik ima pištolj i bubble je već nestao
    else if (isGunPlaced && isBubbleGone) {
      // Sve dok tekst trouble nije izašao van prozora, nek se pomiče dolje
      if (currentTroubleY <= windowHeight + trouble.height/2) {
        currentTroubleY += 5; // Pomak od 5px u svakom frameu
        image(trouble, troubleX, currentTroubleY);
      }
      else { // Kad izađe van prozora, nestao je pa postavljamo isTroubleGone na true
        image(trouble, troubleX, windowHeight + trouble.height/2);
        isTroubleGone = true;
      }
    }

    // Animacija lika
    if (!isTroublePlaced) { // Postavi običnog lika
      image(quitCharacter, windowWidth/5, windowHeight/3);
    }
    else if (isTroubleGone) {
      image(quitCharacter, windowWidth/5, windowHeight/3);
      setIntroCoordinates();
    }
    else{ // Kad su tekstualne animacije gotove, postavi lika s puškom (pomaknut zbog duljine puške)
      image(onePlayerCharacter, windowWidth/4, windowHeight/3);
      isGunPlaced = true;
    }
  
    image(redLayer, windowWidth/2, windowHeight/2); // Postavi sloj crvene boje
    imageMode(CORNER);
    image(arrow, windowWidth - arrow.width, windowHeight - arrow.height); // Postavi gumb strelicu za prelazak na MAINMENU
    popStyle();
  }
  
  
  // ------------------------------------------------------------
  // MAINMENU
  // ------------------------------------------------------------
  if (state == State.MAINMENU) {   
    pushStyle();
    background(menuBackground); // Postavi pozadinu       
    imageMode(CENTER);
    image(redBall, windowWidth/4, windowHeight/4); // Postavi crvenu kuglu

    // Animacija baklje (treperenje vatre)
    if(frameCount % 8 == 0) { // Ako je frameCount djeljiv s 8, crtaj 'fire' sliku
      image(fire, windowWidth/11 , windowHeight/2);
      image(fire, windowWidth/2.46, windowHeight/2);
    }
    else { // Inače crtaj 'torch' sliku
      image(torch, windowWidth/11 , windowHeight/2);
      image(torch, windowWidth/2.46, windowHeight/2);
    }
    
    // Dodavanje gumba za gašenje zvukova
    if(soundOn){
      image(soundOnImg, windowWidth-80, 40);
    } else {
      image(soundOffImg, windowWidth-80, 40);
    }  
    
    // Dodavanje i rotacija slike bubbleTrouble (tekst)
    pushMatrix(); // Za očuvanje stanja (koordinatnog sustava)
    rotate(radians(-15)); // Rotiramo samo 'lokalno'
    image(bubbleTrouble, windowWidth/5, windowHeight/3);
    popMatrix();
    
    //----MENU----
    // Vanjski žuti pravokutnik
    rectMode(RADIUS);
    stroke(183, 180, 16);
    strokeWeight(4);
    fill(255, 252, 0);
    float rectX = windowWidth/4;
    float rectY = 2*windowHeight/3 + 20;
    rect(rectX, rectY, windowWidth/8, windowHeight/4 - 15);
    rectMode(CENTER); 
    // Ukupna visina pravokutnika koji sadržava polja za odabir
    float totalHeight = windowHeight/2 - 50;
    // Postoje 4 polja za odabir, svako visine fieldHeight
    float fieldHeight = totalHeight/4;
    // i će određivati y-koordinatu centra svakog polja za odabir
    float i = fieldHeight/2;
    while (i < totalHeight) {
      // Crtanje crvenih polja za odabir (pravokutnika)
      fill(224, 0, 0);
      rect(rectX, rectY - totalHeight/2 + i, rectX - 20, fieldHeight);
      
      // Pisanje teksta u odgovarajuće pravokutnike
      fill(255, 245, 0);
      textAlign(CENTER, CENTER);
      textFont(menuFont);
      
      update(mouseX, mouseY);       

      // Mijenjanje boje pozadine trenutno odabranog polja te lika na pozadini ovisno o odabranom polju
      // Prvo polje - 1 PLAYER
      if (i < fieldHeight) {
        if (menuPick == MenuPick.ONEPLAYER) {
          image(onePlayerCharacter, 3*windowWidth/4 - 42, windowHeight/2); 
          fill(221, 117, 87);
          rect(rectX, rectY - totalHeight/2 + i, rectX - 20, fieldHeight);
        }
          fill(255, 245, 0);
          text("1 PLAYER", rectX, rectY - totalHeight/2 + i);
      }
      // Drugo polje - 2 PLAYERS
      else if (i < fieldHeight*2) {
        if (menuPick == MenuPick.TWOPLAYERS) {
          image(twoPlayersCharacter, 2*windowWidth/3, windowHeight/2);
          fill(221, 117, 87);
          rect(rectX, rectY - totalHeight/2 + i, rectX - 20, fieldHeight);
        }
        fill(255, 245, 0);
        text("2 PLAYERS", rectX, rectY - totalHeight/2 + i);
      }
      // Treće polje - CONTROLS
      else if (i < fieldHeight*3) {
        if (menuPick == MenuPick.CONTROLS) {
          image(controlsCharacter, 2*windowWidth/3, windowHeight/2);
          fill(221, 117, 87);
          rect(rectX, rectY - totalHeight/2 + i, rectX - 20, fieldHeight);
        }
        fill(255, 245, 0);
        text("CONTROLS", rectX, rectY - totalHeight/2 + i);
      }
      // Četvrto polje - QUIT
      else {
        if (menuPick == MenuPick.QUIT) {
          // slika kao za 1 player
          image(quitCharacter, 2*windowWidth/3, windowHeight/2);
          fill(221, 117, 87);
          rect(rectX, rectY - totalHeight/2 + i, rectX - 20, fieldHeight);
        }
        fill(255, 245, 0);
        text("QUIT", rectX, rectY - totalHeight/2 + i);
      }
      //pomak na iduće polje za odabir
      i += fieldHeight;
    }
    popStyle();
    
    // Nacrtaj zidove koji se pomiču preko svega nacrtanog (to će se vidjeti na početku stanja MAINMENU)
    drawTransition();
    
    //-------------Pritisak gumba Enter-------------
    if (isEnter) {
      resetTransition(); // Prilikom odabira nekog polja, resetiraj tranziciju (postavi koordinate na početne)
      if(soundOn){
        switchSound.play();
      } 
      if (menuPick == MenuPick.ONEPLAYER) {
        play_game(1);
      }
      else if (menuPick == MenuPick.TWOPLAYERS) {
        play_game(2);
      }
      else if (menuPick == MenuPick.CONTROLS) {
        state = State.INSTRUCTIONS;
      }
      else exit();
    }
    
    //-------------Pritisak strelice dolje-------------
    if (isDown) {
      if (menuPick == MenuPick.ONEPLAYER) {
        if(soundOn)
          twoPlayersSound.play(); // Promjena odabira daje zvuk ovisno o odabiru
        menuPick = MenuPick.TWOPLAYERS;
        isDown = false; //inace propada, tj. ulazi u sve uvjete redom
      }
      else if (menuPick == MenuPick.TWOPLAYERS) {
        if(soundOn)
          controlsSound.play();
        menuPick = MenuPick.CONTROLS;
        isDown = false;
      }
      else if (menuPick == MenuPick.CONTROLS) {
        menuPick = MenuPick.QUIT;
        isDown = false;
      }
      else {
        if(soundOn)
          onePlayerSound.play();
        menuPick = MenuPick.ONEPLAYER;  
        isDown = false;
      }
    }
    
    //-------------Pritisak strelice gore-------------
    if (isUp) {
      if (menuPick == MenuPick.ONEPLAYER) {
        menuPick = MenuPick.QUIT;
        isUp = false;
      }
      else if (menuPick == MenuPick.TWOPLAYERS) {
        if(soundOn)
          onePlayerSound.play();
        menuPick = MenuPick.ONEPLAYER;
        isUp = false;
      }
      else if (menuPick == MenuPick.CONTROLS) {
        if(soundOn)
          twoPlayersSound.play();
        menuPick = MenuPick.TWOPLAYERS;
        isUp = false;
      }
      else {
        if(soundOn)
          controlsSound.play();
        menuPick = MenuPick.CONTROLS; 
        isUp = false;
      }
    }
    
   
    
  }
  // ------------------------------------------------------------
  // INSTRUCTIONS
  // ------------------------------------------------------------
  else if (state == State.INSTRUCTIONS) {
    background(instructions); // Postavi pozadinu
    pushStyle();
    imageMode(CENTER);   
    image(menuButton, windowWidth/2, 5*windowHeight/6); // Postavi gumb za povratak u MAINMENU
    popStyle();    
    drawTransition(); // Ulaskom u INSTRUCTIONS vidimo zidove koji se pomiču
  } 
  // ------------------------------------------------------------
  // GAME
  // ------------------------------------------------------------
  else if (state == State.GAME) {
    
    // Provjeri kolizije.
    for (Player player : players) {
      if (player.spearActive)
        ballSpearCollision();
    }
    
    ballPlayerCollision();
    ballTopEdgeCollision();
    
    // Ažuriraj kugle i igrače.
    //for (Ball ball : balls)
     // ball.update();
    for (Player player: players)
      player.update();
    
    // Ponovno iscrtaj pozadinu.
    background(menuBackground);
    //image(levelBackground, (windowWidth - gameWidth)/2, 0, gameWidth, gameHeight);
    fill(level.r, level.g, level.b);
    rect((windowWidth - gameWidth)/2, 0, gameWidth, gameHeight);
    
    // Crtanje bodlji.
    image(thornsImg, (windowWidth - gameWidth)/2+1, 0);
    
    // Crtanje gumba za pauzu.
    image(pauseImg, windowWidth-100, 25);
    
    // Crtanje gumba za restartanje igre.
    image(restartImg, windowWidth-55, 25);
  
    // Nacrtaj igrače i lopte.
    for (Player player: players)
      if (player.lives > 0 || player.just_lost_life) player.draw();
    for (Ball ball : balls)
      ball.draw();
         
    // Trenutno će koplje "izlaziti" iz okvira igre pa treba još
    // jednom iscrtati dio pozadine.
    image(menuBackgroundSmall, 0, gameHeight);
   
    
    //Ubacivanje slicica na kojima pise Player1, Player2
    image(player1_text, (windowWidth - gameWidth)/2, windowHeight - 40 - 42+7);
    image(player2_text, windowWidth - (windowWidth-gameWidth)/2 - 175, windowHeight - 40 - 40+7);
    stroke(150);
    strokeWeight(4);
    fill(194,194,193);
    rect((windowWidth-gameWidth)/2 + player1_text.width + 5, windowHeight - 40 - 42 + 12, 120, 35);
    rect(windowWidth - (windowWidth-gameWidth)/2 - 175 - 120 - 8, windowHeight - 40 - 40 + 9, 122, 37);
    stroke(0);
    strokeWeight(1);

    //Ispis života
    int j = 0;
    textFont(gameFont);
    textAlign(CENTER, CENTER);
    fill(120);
    //ako igraju oba igraca
    for (Player player : players) {
         PImage lives;
         String img_name = "lives";
         if(player.lives == -1) {
            img_name += "0.png"; //zbog trika s game over
         } else {
            img_name += player.lives + ".png";
         }
         try {
           lives = loadImage(img_name);
           if(j==0) {
             image(lives, (windowWidth - gameWidth)/2, windowHeight - 82 - 30 - 5+7);
             text(player.overall_points + player.level_points, (windowWidth-gameWidth)/2 + player1_text.width + 80, windowHeight - 58+7);
           } else {
             image(lives, windowWidth - (windowWidth-gameWidth)/2 - 306, windowHeight - 82 - 30 - 5+7);
             text(player.overall_points + player.level_points, windowWidth - (windowWidth-gameWidth)/2 - 175 - 50, windowHeight - 58+7);
           }
         } catch (Exception e) {
           print("Slika ne postoji ili je greska u broju zivota.");
         }
         j++;
    }
    
    fill(255);
    
    //ako igra samo jedan, onda drugom ispisemo kao da ima 0 zivota
    if(players.size() == 1) {
      try {
        PImage lives = loadImage("lives0.png");
        image(lives, windowWidth - (windowWidth-gameWidth)/2 - 306, windowHeight - 82 - 30 - 5+7) ;
      } catch (Exception e) {
        print("Slika ne postoji");
      }
    }
    
    //Ispis levela i baklji
    setLevelImg(); //učitava sliku levela
    image(levelImg, windowWidth/2 - 136/2, windowHeight - 30 - 90 + 15);
    image(torch, windowWidth/2 - 124/2 - 50 - 33, gameHeight + (windowHeight - gameHeight)/2 - 118/2 + 12);
    image(torch, windowWidth/2 + 124/2 + 50, gameHeight + (windowHeight - gameHeight)/2 - 118/2 + 12);
    
    
    // Ispis vremenske trake
    int remaining_millis = level.time - (millis() - millis) + paused_millisecs;
    if (lostLife || level_done) remaining_millis = level.time - (temp_millisecs - millis) + paused_millisecs;
    else if (get_ready) remaining_millis = level.time;
    if (remaining_millis <= 0) {
      remaining_millis = 0;
      if (!times_up) {
        times_up = true;
        temp_millisecs = millis();
      }
    }
    float percent = (float)remaining_millis/level.time;
    fill(87, 81, 81);
    stroke(200);
    rect((windowWidth - gameWidth)/2, gameHeight+6, gameWidth, 18);
    fill(204, 47, 8);
    strokeWeight(0);
    rect((windowWidth - gameWidth)/2+3, gameHeight+8, (gameWidth-5)*percent, 14);
    fill(255);
    stroke(0);
    strokeWeight(1);
   
    drawTransition(); // Crtanje zidova koji se pomiču
    
    // Crtanje supermoći koje padaju ili nisu pokupljene.
    if(activeSuperpower != ""){
      //supermoć je u zraku
      if((int)ySuperpowerPosition != gameHeight-superpowerHeight){
        ySuperpowerPosition += 1;     
        image(activeSuperpowerImg, xSuperpowerPosition-(superpowerWidth/2), ySuperpowerPosition, superpowerWidth, superpowerHeight);
        // pamti vrijeme kad je supermoć dotaknula pod
        superpower_millisecs = millis();
      }
      else{
        // Vrijeme za koje igrač može pokupiti supermoć s poda.
        if(millis() - superpower_millisecs <= 3000){
          image(activeSuperpowerImg, xSuperpowerPosition-(superpowerWidth/2), gameHeight-superpowerHeight, superpowerWidth, superpowerHeight);
        }
        else
          activeSuperpower = "";        
      }
      
      // Provjera je li igrač pokupio supermoć.
      superpowerPlayerCollision();      
    }     
    
    // Ako je igrač izgubio život, ali još uvijek ima preostale živote:
    if(lostLife && !is_game_over) {
      // Pišemo prikladni tekst za kratak period vremena:
      if (millis() - delay_millisecs <= 800)
        write_dummy_text("OUCH");
      else {
        lostLife = false;
        // Nakon tog vremena, ponovno postavimo pozicije igrača.
        for (Player player_: players){
          player_.resetPosition();
          player_.resetOrientation();
          player_.resetState();
        }
        // Ponovno postavljamo level.
        level = new Level(current_level);
        // Ponovno postavljamo kugle.
        balls.clear();
        balls = level.balls;
        superpowers = level.superpowers;
        // Ponovno postavljamo bodove
        for (Player player : players) player.level_points = 0;
        // Deaktiviramo moć ako je bila aktivna.
        activeSuperpower = "";
        // Ponovno pokrećemo vrijeme:
        millis = millis();
        // Naznačimo da je sad trenutak kad se igrač treba spremati za ponovni početak igre.
        get_ready = true;
        getReady_millisecs = millis();
        paused_millisecs = 0;
        // I ponovno 'pauziramo' igru (tj zaustavimo nove loptice).
        pause_game();
      }
     }
     
     if(get_ready) {
       for (Player player: players) player.just_lost_life = false;
       // Opet određeni kratki interval upozravamo igrača da se spremi za novi pokušaj.
       if (millis() - getReady_millisecs <= 1000)
        write_dummy_text("GET READY");
       else {
         // Nakon tog vremena, ponovno pokrenemo lopte.
         millis = millis();
         get_ready = false;
         restart_the_balls();
       }
     }
    
    // Ako je isteklo vrijeme
    if (times_up) {
      pause_game();
      if (millis() - temp_millisecs < 1000)
        write_dummy_text("Time's up!");
      else {
        boolean _over = true;
        for(Player player : players) { 
          if (player.lives > 0) player.lives--;
          if (player.lives > 0) _over = false;
        }
        times_up = false;
        is_game_over = _over;
        if (!_over) {
          for (Player player_: players){
            player_.resetPosition();
            player_.resetOrientation();
            player_.resetState();
          }
          // Ponovno postavljamo level.
          level = new Level(current_level);     
          // Ponovno postavljamo kugle.
          balls.clear();
          balls = level.balls;
          // Ponovno postavljamo supermoći. 
          superpowers = level.superpowers;
          // Ponovno postavljamo bodove
          for (Player player : players) player.level_points = 0;
          // Ponovno pokrećemo vrijeme:
          millis = millis();
          // Naznačimo da je sad trenutak kad se igrač treba spremati za ponovni početak igre.
          get_ready = true;
          getReady_millisecs = millis();
          paused_millisecs = 0;
          // I ponovno 'pauziramo' igru (tj zaustavimo nove loptice).
          pause_game();
        }
        
      }
        
    }
    
    // Ako je igra gotova ili ako je zadnji level
    if(is_game_over || game_completed) {
      for (Player player : players) player.overall_points += player.level_points;
      
      //pamtimo koje je trenutno vrijeme
      if(!timer){
        gameover_millisecs = millis();
        timer = true;
      }
      
      //prvo ispisemo poruku na 1 sek, a zatim prebacimo na result
      if (millis() - gameover_millisecs <= 1000) {
        
        if(is_game_over) {
          write_dummy_text("GAME OVER");
        } else if( game_completed) {
          write_dummy_text("YOU WIN");
        }
         
      } else { 
        resetTransition();
        if(soundOn) {
          switchSound.play();
        }
        state = State.RESULTS;
      }
    }
    
    // Ako je neki drugi level pobjeđen, prikazuje se odgovarajuća poruka i prelazi na novi level.
    else if (level_done) {
      if (!new_points_added) {
        for (Player player : players)
          player.overall_points += player.level_points;
        new_points_added = true;
      }
      // Ponovno postavljamo bodove
      for (Player player : players) player.level_points = 0;
      if (millis() - levelWon_millisecs <= 2000)
        write_dummy_text("Level done!");
      else{
        new_points_added = false;
        level_done = false;
        paused_millisecs = 0;
        restart_the_balls();
        millis = millis();
      }        
    }
    }
    // ------------------------------------------------------------
    // PAUSE
    // ------------------------------------------------------------
    else if (state == State.PAUSE) {
        unsetMoves(); // Za svaki slučaj deaktiviramo tipke.
        textAlign(CENTER, CENTER);      
        stroke(183, 180, 16);
        strokeWeight(4);
        fill(255, 245, 0);
        int _width = 450;
        float rectX = windowWidth/2;
        float rectY = windowHeight/2;
        rect(rectX-_width/2, rectY-80-20, _width, 80);
        rect(rectX-_width/2, rectY+10, _width, 80);
        fill(224, 0, 0);
        rectX = windowWidth/2-_width/2+8;
        rectY = windowHeight/2-92;
        rect(windowWidth/2-_width/2+8, windowHeight/2-92, _width-16, 64);
        rect(windowWidth/2-_width/2+8, windowHeight/2+18, _width-16, 64);
        fill(255, 245, 0);
        textSize(25);
        text("resume", windowWidth/2, windowHeight/2-60);
        text("main menu", windowWidth/2, windowHeight/2+50);
        fill(255);
        stroke(0);
        strokeWeight(1);
    }
    // ------------------------------------------------------------
    // RESULTS
    // ------------------------------------------------------------
    else if (state == State.RESULTS) { 
    
      background(menuBackground);
      imageMode(CENTER);
      image(redBall, windowWidth/4, windowHeight/4);
      pushMatrix();
      rotate(radians(-15));
      image(bubbleTrouble, windowWidth/5, windowHeight/3);
      popMatrix();
      
      imageMode(CORNER);
      float imgX = windowWidth/4 - redBall.width/2;
      float imgY = windowHeight/4 + redBall.height/2 + 80 + 10; //(+10 zbog poruke o zavrsetku igre)
      image(player1_text, imgX, imgY);
      image(player2_text, imgX, imgY + 80);
      
      stroke(145);
      strokeWeight(4);
      fill(200);
      float recX = imgX + player1_text.width + 20;
      float recY = imgY + 2;
      rect(recX, recY, 150, player1_text.height - 4);
      rect(recX, recY + 80, 150, player2_text.height - 4);
      
      int j=0;
      textFont(gameFont);
      textAlign(CENTER,CENTER);
      fill(110);
      for(Player player: players) {
        if(j==0) {
          text(player.overall_points, recX + 150/2, recY + player1_text.height/2);
        } else {
          text(player.overall_points, recX + 150/2, recY + player2_text.height/2 + 80);
        }
        j++;
      }
        
      image(menuButton, windowWidth/2 - menuButton.width/2, windowHeight - menuButton.height - 50);

      fill(255);
      stroke(0);
      strokeWeight(1);
      
      drawTransition();
    }
}

// ------------------------------------------------------------
// Interakcija s tipkovnicom/mišem.
// ------------------------------------------------------------
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

void mousePressed(){ 
   
  // Odabir opcija MENUa u stanju MAINMENU
  if(state == State.MAINMENU){
    // 1 player
    if(overOnePlayer(mouseX, mouseY)){
        resetTransition();
        if(soundOn){
          switchSound.play();
        } 
        play_game(1);  
    }
    // 2 players
    if(overTwoPlayers(mouseX, mouseY)){
        resetTransition();
        if(soundOn){
          switchSound.play();
        } 
        play_game(2);
    }
    // controls
    if(overControls(mouseX, mouseY)){
        resetTransition();
        if(soundOn){
          switchSound.play();
        } 
        state = State.INSTRUCTIONS;
    }
    // quit
    if(overQuit(mouseX, mouseY)){
        resetTransition();
        if(soundOn){
          switchSound.play();
        } 
        exit();
    }
  } 
  
  //Provjeravamo je li korisnik kliknuo na mute button
  if ((mouseX >= (windowWidth - 80-20) && mouseX <= (windowWidth - 80 + 20)) && (mouseY >= 25 && mouseY <= 55) && state == State.MAINMENU){
    
    if(soundOn) {
     soundOn = false;
    }
    else {
     soundOn = true;
    }
  }
  
  if((mouseX >= (windowWidth/2 - 80))  && (mouseX <= (windowWidth/2 + 80)) && (mouseY >= (5*windowHeight/6 - 45)) && (mouseY <= (5*windowHeight/6 + 45)) && state == State.INSTRUCTIONS) {
    resetGame();
  }
  
  // Provjera je li korisnik kliknuo pauzu.
  if((mouseX >= (windowWidth - 80-20) && mouseX <= (windowWidth - 80 + 20)) && (mouseY >= 25 && mouseY <= 55) && state == State.GAME){
    temp_millisecs = millis();
    state = State.PAUSE;
  }
  
  if(state == State.PAUSE){
    if((mouseX >= (windowWidth/2 - 450/2) && mouseX <= (windowWidth/2 + 450/2)) && mouseY >= (windowHeight/2 - 100) && mouseY <= (windowHeight/2 - 20)){
      paused_millisecs += millis() - temp_millisecs;
      state = State.GAME;
    }
    else if(mouseX >= (windowWidth/2 - 450/2) && mouseX <= (windowWidth/2 + 450/2) && mouseY >= (windowHeight/2 + 10) && mouseY <= (windowHeight/2 + 90)){
      if(soundOn)
        switchSound.play();
      resetGame();    
    }    
  }
  
  //Provjera je li korisnik kliknuo na resetBtn
  if( mouseX >= (windowWidth - 55) && mouseX<= (windowWidth - 55 + restartImg.width) && mouseY >= 25 && mouseY <= (25 + restartImg.height) && state == State.GAME) {
      resetTransition();
      if(soundOn) {
        switchSound.play();
      }
      
      if(players.size() == 1) play_game(1);
      else if(players.size() == 2) play_game(2);
  }
  
  // Provjera je li korisnik kliknuo na gumb meni u State.RESULTS
  if( mouseX >= (windowWidth/2 - menuButton.width/2) && mouseX <= (windowWidth/2 + menuButton.width/2) && mouseY>= (windowHeight - menuButton.height - 50) && mouseY<= (windowHeight - 50) && state == State.RESULTS) {
     if(soundOn)
       switchSound.play();
     resetGame();
  }
  
  // Provjera je li korisnik kliknuo na gumb strelica u State.INTRO
  if( (mouseX >= (windowWidth - arrow.width)) && (mouseX <= windowWidth) && (mouseY >= windowHeight - arrow.height) && (mouseY <= windowHeight) && (state == State.INTRO) ) {
    introSong.stop();
    switchSound.play();
    state = State.MAINMENU;
  }
}

// ------------------------------------------------------------
// Aktivacija varijabli za pritisak tipki na tipkovnici.
// ------------------------------------------------------------
void setMove(int k, boolean b) {
  // Standardne left-right tipke za prvog igrača.
  // Ako je igra gotova ili je tama izgubljen život ili mso u get-ready fazi,
  // ne želimo da se igrači mogu i dalje micati. Isto vrijedi i ako trenutno
  // nismo u igri (lijevo-desno se ne koristi u meniju).
  switch (k) {
  case LEFT:
    if (is_game_over || times_up || lostLife || get_ready || level_done || state != State.GAME) return;
    isLeft = b;
    if (b)
      players.get(0).orientation = PlayerOrientation.LEFT;
    else
      players.get(0).orientation = PlayerOrientation.BACK;
    return;

  case RIGHT:
    if (is_game_over || times_up || lostLife || get_ready || level_done || state != State.GAME) return;
    isRight = b;
    if (b)
      players.get(0).orientation = PlayerOrientation.RIGHT;
    else
      players.get(0).orientation = PlayerOrientation.BACK;
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
  // Ako je igra gotova ili je tama izgubljen život ili mso u get-ready fazi,
  // ne želimo da se igrači mogu i dalje micati. Isto vrijedi i ako trenutno
  // nismo u igri.
  
  // NAPOMENA: Ako se dodaju neke kontrole (koje se koriste izvan same igre) ovdje, treba
  // ovaj state != State.GAME prebaciti unutra jer inače pritisak tipki neće imati
  // nikakav učinak.
  if (is_game_over || lostLife || get_ready || level_done || state != State.GAME) return;
  switch (k) {
  // Tipka za koplje prvog igrača.
  case ' ':
    isSpace = b;
    return;
  
  // Ove tipke ne smiju imati nikakav učinak kad se igra sa samo jednim
  // igračem, tj. kad je quantity == 1.
  // Sve tipke za drugog igrača: a-lijevo, d-desno, s-koplje
  case 'a':
    if (quantity == 1) return;
    isA = b;
    if (b)
      players.get(1).orientation = PlayerOrientation.LEFT;
    else
      players.get(1).orientation = PlayerOrientation.BACK;
    return;
    
  case 'A':
    if (quantity == 1) return;
    isA = b;
    if (b)
      players.get(1).orientation = PlayerOrientation.LEFT;
    else
      players.get(1).orientation = PlayerOrientation.BACK;
    return;

  case 'd':
    if (quantity == 1) return;
    isD = b;
    if (b)
      players.get(1).orientation = PlayerOrientation.RIGHT;
    else
      players.get(1).orientation = PlayerOrientation.BACK;
    return;
    
  case 'D':
    if (quantity == 1) return;
    isD = b;
    if (b)
      players.get(1).orientation = PlayerOrientation.RIGHT;
    else
      players.get(1).orientation = PlayerOrientation.BACK;
    return;
  
  case 's':
    if (quantity == 1) return;
    isS = b;
    return;
    
  case 'S':
    if (quantity == 1) return;
    isS = b;
    return;
  }
}
// ------------------------------------------------------------
// Deaktivacija svih varijabli za pritisak tipki na tipkovnici.
// ------------------------------------------------------------
void unsetMoves() {
  isLeft = isRight = isSpace = false;
  isA = isD = isS = false;
  isUp = isDown = isEnter = false;
}

// Funkcija koja obrađuje kraj (pobjedu) levela:
void levelWon() {
  int seconds_passed = (millis() - millis)/1000;
  for (Player player : players) {
    if (player.lives > 0) player.level_points += (level.time/1000-seconds_passed)*5;
  }
  
  level_done = true;
  temp_millisecs = millis();
  if(soundOn)
    levelDoneSound.play();
    
  //Deaktiviramo aktivnu moć ako je bilo.
  activeSuperpower = "";
    
  // Ponovno postavimo pozicije igrača.
  for (Player player_: players){
    player_.resetPosition();
    player_.resetOrientation();
    player_.resetState();    
  }
  
  // Postavljamo kugle i supermoći za odgovarajući level.
  if(current_level < 5){
    level = new Level(++current_level);
    setLevelImg();
    /*String levelImgName = "level" + str(current_level) + ".png";
    try{
      levelImg = loadImage(levelImgName);
    } catch (Exception e) {
      print("Slika ne postoji");
    }*/
    balls = level.balls;
    superpowers = level.superpowers;
  }
  else if(current_level == 5){
    game_completed = true;
  }  
  
  pause_game();
}

void setLevelImg() {
  String levelImgName = "level" + str(current_level) + ".png";
    try{
      levelImg = loadImage(levelImgName);
    } catch (Exception e) {
      print("Slika ne postoji");
    }
}

// Funkcija koja aktivira supermoć ako već nije aktivirana neka druga i vraća informaciju o uspješnom/neuspješnom aktiviranju.
boolean superpowerSpearCollision(String _superpower, float x, float y, Player _player){
  if (activeSuperpower != "")
    return false;
    
  // Igrač može imati najviše 9 života.
  if(_superpower == "life" && _player.lives == 9)
    return false;
    
  activeSuperpower = _superpower;
  activeSuperpowerImg = loadImage(activeSuperpower + ".png");
  xSuperpowerPosition = x;
  ySuperpowerPosition = y;    
  return true;
}

// Funkcija za detekciju kolizije supermoći i igrača.
void superpowerPlayerCollision(){
  // Za svakog igrača (prva for petlja) gledamo dolazi li do kolizije i potom postupamo prikladno.
  for (Player player : players) {    
    if(player.checkSuperpowerCollision(xSuperpowerPosition, ySuperpowerPosition)){
      switch(activeSuperpower){        
        case "shield": 
          player.state = PlayerState.SHIELD;
          activeSuperpower = "";
          return;
        
        case "life":
          ++player.lives;
          activeSuperpower = "";
          return;      
      }  
    }
  }
}

// Funkcija koja pauzira igru.
void pause_game() {
  // Brzinu svih loptica postavljamo na 0, tako ih možemo 'pauzirati' pri završetku igre:
  for (Ball ball : balls) {
    ball.xVelocity = 0;
    ball.yVelocity = 0;
  }
  // Završavamo efekte svih tipki:
  unsetMoves();
}

// Funkcija koja prikazuje završni rezultat i preusmjerava na main menu:
void game_over() {
  is_game_over = true;
  pause_game();
}

// ------------------------------------------------------------
// Detekcija kolizija.
// ------------------------------------------------------------
// Funkcija za detekciju kolizije lopti i koplja.
void ballSpearCollision() {
  // Za svakog igrača (prva for petlja) i svaku loptu (druga for petlja)
  // gledamo dolazi li do kolizije i potom postupamo prikladno.
  for (Player player : players) {
    for (int i = balls.size() - 1; i >= 0; --i)
      if (balls.get(i).checkSpearCollision(player.xSpear, player.ySpear)) {

        // Ako je igrač udario lopticu određene veličine (prvu takvu) u kojoj se nalazi supermoć (ovisno o levelu) aktivira se supermoć.
        if(balls.get(i).sizeLevel > 1 && superpowers[balls.get(i).sizeLevel - 2] != ""){
            if(superpowerSpearCollision(superpowers[balls.get(i).sizeLevel - 2], balls.get(i).xCenter, balls.get(i).yCenter, player))
              superpowers[balls.get(i).sizeLevel - 2] = "";  //ako je bila aktivirana, supermoć je iskorištena
        }
          
        splitBall(i, player, false);
        player.resetSpear();                
   }
  }
}

// Funkcija za detekciju kolizije lopti i igrača.
void ballPlayerCollision() {
  if (is_game_over || lostLife) return;
  // Također prolazimo po svim igračima i loptama i provjeravamo dolazi li do kolizije.
  for (Player player : players) {
    if(player.lives <= 0) continue;
    for (int i = 0; i < balls.size(); ++i) {
      Ball current = balls.get(i);
      if (current.checkPlayerCollision(player.position)) {      
        if(player.state == PlayerState.SHIELD){
          
          if(current.sizeLevel == 1)
            balls.remove(i);
          else
            splitBall(i, player, false);
          
          player.state = PlayerState.REGULAR;
            if (balls.isEmpty()){
              levelWon_millisecs = millis();
              levelWon();
            }
        }        
        else{          
          if (!current.is_being_hit) {
            --player.lives;
            if(soundOn) {
              player.stopSpearSound();
              punchSound.play();
            }
            // Ako je kolizija tek počela, postavljamo atribut na true.
            // Ovime izbjegavao da se odjednom oduzme nekoliko života umjesto jednog.
            current.is_being_hit = true;
            player.resetSpear(); //maknemo i strelice od tog igrača
            delay_millisecs = millis();
            pause_game();
            lostLife = true;
            temp_millisecs = millis();          
            player.just_lost_life = true;
          }
          // Varijabla kojom brojimo koliko igrača je izgubilo:
          int no_of_over = 0;
          for (Player player_: players)
            if (player_.lives <= 0) no_of_over += 1;
          // Ako su svi igrači izgubili igru, idemo na game_over:
          if (no_of_over == players.size()) {
            // Mali trik: smanjujemo broj života zadnjeg igrača na -1,
            // kako bismo ga ipak mogli crtati u sudaru s lopticom pri potpunom gubitku igre. 
            --player.lives;
            game_over();
            return;
          }
  
          // Ali, ako jedan igrač izgubi, drugi još ostaje!
          if (player.lives <= 0) no_of_over += 1;
        }
      }
      else current.is_being_hit = false; // Ako kolizije više nema, postavljamo atribut na false.
    }
  }
}

// Funkcija koja provjerava je li ikoja od lopti udarila
// u gornji rub ekrana (tada ona nestaje).
void ballTopEdgeCollision() {
  // Idemo unatrag zbog eventualnog brisanja lopte.
  for (int i = balls.size() - 1; i >= 0; --i) {
    Ball ball = balls.get(i);  // Dohvati i-tu loptu.
    // Razdvoji je ako je udarila u bodlje, koje su visine 30px.
    if (ball.yCenter - ball.radius <= 30)
      splitBall(i, players.get(ball.hitByPlayer - 1), true);
  }  
}

// Funkcija koja se brine o razdvajanju i-te lopte u dvije te
// pridodaje bodove igraču player.
void splitBall(int i, Player player, boolean topEdge) {
  Ball ball = balls.get(i);
  
  if (topEdge) player.level_points += (6-ball.sizeLevel+1)*20;
  else player.level_points += (6-ball.sizeLevel+1)*10;
  print(player.level_points, "\n");
  // player.resetSpear();
  if (ball.sizeLevel > 1) {
    if(soundOn) {
      player.stopSpearSound(); //prestaje reprodukcija zvuka strelice
      collisionSound.play(); //reproduciramo zvuk pogotka
    }
    balls.add(new Ball(ball.xCenter, ball.yCenter, 
                      ball.sizeLevel-1, 1, -3, 
                      ball.yCenter, player.no_player,
                      ball.ballColor));
                      
    balls.add(new Ball(ball.xCenter, ball.yCenter, 
                      ball.sizeLevel-1, -1, -3, 
                      ball.yCenter, player.no_player,
                      ball.ballColor));
  }
  balls.remove(i);
  if (balls.isEmpty()){
    levelWon_millisecs = millis();
    levelWon();
  }
  return;
}
