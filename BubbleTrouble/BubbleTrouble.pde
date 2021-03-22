 //<>//
import processing.sound.*;

// Veličina okvira za igru.
final float gameWidth = 1024, gameHeight = 576;
// Veličina prozora.
final float windowWidth = 1280, windowHeight = 720; // Ako se mijenja, treba promijeniti size u setup().
// Postavljamo broj igrača i kreiramo listu u koju ćemo kasnije igrače pohranjivati.
int quantity;
ArrayList<Player> players = new ArrayList<Player>();
// Lista u kojoj se čuvaju sve lopte trenutno na ekranu.
ArrayList<Ball> balls = new ArrayList<Ball>();
// Varijabla koja pohranjuje istinu ako je igra gotova, inače laž
boolean is_game_over = false;
// Varijabla koja pamti je li u tijeku čekanje ponovnog početka igre.
boolean get_ready = false;
// Varijable koja pamti je li završen level:
boolean level_done = false;
// Varijabla u kojoj pohranjujemo mogući broj bodova.
int max_points;
// Varijable za pohranjivanje vremena (dovoljno je uzeti minute i sekunde):
int minutes, seconds, delay_millisecs, getReady_millisecs;

//slike u MAINMENU
PImage character, bubbleTrouble, redBall, torch, soundOnImg, soundOffImg, menuBackground, instructions, menuButton;
PImage bottomWall, topWall; // polovice zidova koje se pomiču
PImage menuBackgroundSmall; // Za pokrivanje koplja, crta se u draw() kad je state == GAME.
PImage player1_text, player2_text;
PImage fire;
PImage level1;
PFont menuFont;
PFont gameFont;


float transitionFactor = 5; // Za koliko se piksela zid pomiče svaki frame
float bottomWallHeight = windowHeight/2 - transitionFactor;
float topWallHeight = transitionFactor;
float totalMoveCtr = 0; // Kontrola izlaženja van ekrana, kada pomicanje više nije potrebno
boolean openWall = true; // true kada se zid 'otvara', false kada se 'zatvara'

//slike igrača
ArrayList<PImage> player1_images;
ArrayList<PImage> player2_images;

// Slika koplja.
PImage spearImg;

// Visine do kojih loptice različitih levela veličine skaču.
// Uvijek je isto za loptice istih veličina (ovisi o gameHeight)
// pa se računa samo jednom u setup().
float[] ballJumpHeight;
float[] splitBallJumpHeight; // Visina poskoka loptice nakon razbijanja.

boolean isLeft, isRight, isSpace, isA, isD, isS, isUp, isDown, isEnter;
final int ENTER_CODE = 10; // Moze biti problema s ovim

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

SoundFile introSong;
SoundFile shootingSound;
SoundFile collisionSound;
SoundFile switchSound;
SoundFile punchSound;
SoundFile levelDoneSound;
String path;

SoundFile getShootingSound(){
    return shootingSound;
}

boolean soundOn = true;
boolean getSound() {
  return soundOn;
}

boolean lostLife = false;

void setup() {
  
  size(1280, 720);
  is_game_over = false;
  level_done = false;
  balls.clear();
  balls.add(new Ball(windowWidth/2, gameHeight/2, 4));
  // Pamtimo vrijeme početka radi kasnijeg računanja bodova:
  minutes = minute();
  seconds = second();
  
  //učitavanje slika za MAINMENU
  character = loadImage("character.png");
  bubbleTrouble = loadImage("bubbleTrouble.png");
  redBall = loadImage("redBall.png");
  torch = loadImage("torch.png");
  soundOnImg = loadImage("soundOn.png");
  soundOffImg = loadImage("soundOff.png");
  menuBackground = loadImage("menuBackground2.png"); // Napomena: Koristi se i u crtanju igre kad je state == GAME.
  instructions = loadImage("instructions.png");
  menuButton = loadImage("menuButton.png");
  player1_text = loadImage("player1_text.png");
  player2_text = loadImage("player2_text.png");
  level1 = loadImage("level1.png");
  topWall = loadImage("topWall.png");
  bottomWall = loadImage("bottomWall.png");
  fire = loadImage("fire.png");
  
  //učitavanje fonta za MAINMENU
  menuFont = loadFont("GoudyStout-28.vlw");
  
  //učitavanje fonta za GAME
  gameFont = loadFont("GoudyStout-20.vlw");
  
  path = sketchPath("");
  path = path + "\\sounds\\";
  introSong = new SoundFile(this, path + "intro.mp3");
  shootingSound = new SoundFile(this, path + "shooting.mp3");
  collisionSound = new SoundFile(this, path + "collision.mp3");
  switchSound = new SoundFile(this, path + "switch.mp3");
  punchSound = new SoundFile(this, path + "punch.mp3");
  levelDoneSound = new SoundFile(this, path + "end_of_level.mp3");
  
  //ako je korisnik pritisnuo enter, znaci da je odabrao jednu od opcija igre i ponovno se poziva setup, a ne zelimo da se intro ponovno reproducira
  if(soundOn && !isEnter)
    introSong.loop();
  
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

void createPlayers() {
  // Ovisno o postavljenom broju igrača, popunjavamo listu i podešavamo početne pozicije
  players.clear();
  for (int i = 0; i < quantity; i++)
    players.add(new Player((i+1)*windowWidth/(quantity+1)-25, i+1));
    ellipseMode(RADIUS); // Crtanje kružnica kao (srediste.x, srediste.y, radijus).
}

// Pomoćna funkcija za pisanje poruka tokom igre:
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
    ball.xVelocity = 1;
    ball.yVelocity = 3;
  }
}

// Funkcija za crtanje zida koji se pomiče pri prijelazu s glavnog izbornika u igru
void draw_transition(boolean openWall) {
  if (topWall.height - totalMoveCtr > 0 && openWall) {
    topWallHeight -= transitionFactor;
    bottomWallHeight += transitionFactor;
    image(topWall, 0, topWallHeight);
    image(bottomWall, 0, bottomWallHeight);
    totalMoveCtr += transitionFactor;
  }
  // nije bas dobro jos i ne znan di koristit tocno
  else if (topWall.height - totalMoveCtr > 0 && !openWall) {
    topWallHeight -= transitionFactor;
    bottomWallHeight += transitionFactor;
    image(topWall, 0, bottomWallHeight - windowHeight/2 - topWall.height);
    image(bottomWall, 0, topWallHeight + windowHeight);    
    totalMoveCtr += transitionFactor;
  }
}

// Funkcija za resetiranje tranzicije
void reset_transition() {
  bottomWallHeight = windowHeight/2 - transitionFactor;
  topWallHeight = transitionFactor;
  totalMoveCtr = 0;  
}

// Vraćanje u glavni izbornik tako da odabir bude defaultan te se zvuk pokrene
void reset_game() {
  state = State.MAINMENU;
  menuPick = MenuPick.ONEPLAYER;
  reset_transition();
  if(soundOn) 
    introSong.loop();
}

void draw() { 
  // ------------------------------------------------------------
  // MAINMENU
  // ------------------------------------------------------------
  if (state == State.MAINMENU) {   
    // pushStyle() i popStyle() za očuvanje trenutnog stila i naknadno vraćanje istog
    pushStyle();
    background(menuBackground);
         
    // Dodavanje lika, crvene kugle i baklji
    imageMode(CENTER);
    image(character, 2*windowWidth/3, windowHeight/2);
    image(redBall, windowWidth/4, windowHeight/4);

    if(frameCount % 8 == 0) {
      image(fire, windowWidth/11 , windowHeight/2);
      image(fire, windowWidth/2.46, windowHeight/2);
    }
    else {
      image(torch, windowWidth/11 , windowHeight/2);
      image(torch, windowWidth/2.46, windowHeight/2);
    }
    
    //Dodavanje gumba za gašenje zvukova
    if(soundOn){
      image(soundOnImg, windowWidth-80, 40);
    } else {
      image(soundOffImg, windowWidth-80, 40);
    }
   
    
    // Dodavanje i rotacija slike bubbleTrouble (tekst)
    pushMatrix();
    rotate(radians(-15));
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
      // Mijenjanje boje pozadine trenutno odabranog polja
      // Prvo polje - 1 PLAYER
      if (i < fieldHeight) {
        if (menuPick == MenuPick.ONEPLAYER) {
          fill(221, 117, 87);
          rect(rectX, rectY - totalHeight/2 + i, rectX - 20, fieldHeight);
        }
          fill(255, 245, 0);
          text("1 PLAYER", rectX, rectY - totalHeight/2 + i);
      }
      // Drugo polje - 2 PLAYERS
      else if (i < fieldHeight*2) {
        if (menuPick == MenuPick.TWOPLAYERS) {
          fill(221, 117, 87);
          rect(rectX, rectY - totalHeight/2 + i, rectX - 20, fieldHeight);
        }
        fill(255, 245, 0);
        text("2 PLAYERS", rectX, rectY - totalHeight/2 + i);
      }
      // Treće polje - CONTROLS
      else if (i < fieldHeight*3) {
        if (menuPick == MenuPick.CONTROLS) {
          fill(221, 117, 87);
          rect(rectX, rectY - totalHeight/2 + i, rectX - 20, fieldHeight);
        }
        fill(255, 245, 0);
        text("CONTROLS", rectX, rectY - totalHeight/2 + i);
      }
      // Četvrto polje - QUIT
      else {
        if (menuPick == MenuPick.QUIT) {
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
    
    
    draw_transition(true);
    // Pritisak gumba Enter
    if (isEnter) {
      reset_transition();
      if(soundOn){
        introSong.stop();
        switchSound.play();
      } 
      if (menuPick == MenuPick.ONEPLAYER) {
        quantity = 1;
        createPlayers();
        state = State.GAME;
        setup();
      }
      else if (menuPick == MenuPick.TWOPLAYERS) {
        quantity = 2;
        createPlayers();
        state = State.GAME;
        setup();
      }
      else if (menuPick == MenuPick.CONTROLS) {
        state = State.INSTRUCTIONS;
      }
      else exit();
    }
    
    // Pritisak strelice dolje
    if (isDown) {
      if (menuPick == MenuPick.ONEPLAYER) {
        menuPick = MenuPick.TWOPLAYERS;
        isDown = false; //inace propada, tj. ulazi u sve uvjete redom
      }
      else if (menuPick == MenuPick.TWOPLAYERS) {
        menuPick = MenuPick.CONTROLS;
        isDown = false;
      }
      else if (menuPick == MenuPick.CONTROLS) {
        menuPick = MenuPick.QUIT;
        isDown = false;
      }
      else {
        menuPick = MenuPick.ONEPLAYER;  
        isDown = false;
      }
    }
    
    // Pritisak strelice gore
    if (isUp) {
      if (menuPick == MenuPick.ONEPLAYER) {
        menuPick = MenuPick.QUIT;
        isUp = false;
      }
      else if (menuPick == MenuPick.TWOPLAYERS) {
        menuPick = MenuPick.ONEPLAYER;
        isUp = false;
      }
      else if (menuPick == MenuPick.CONTROLS) {
        menuPick = MenuPick.TWOPLAYERS;
        isUp = false;
      }
      else {
        menuPick = MenuPick.CONTROLS; 
        isUp = false;
      }
    }
    
    
  }
  // ------------------------------------------------------------
  // INSTRUCTIONS
  // ------------------------------------------------------------
  else if (state == State.INSTRUCTIONS) {
    introSong.stop();
    background(instructions);
    pushStyle();
    imageMode(CENTER);   
    image(menuButton, windowWidth/2, 5*windowHeight/6);
    popStyle();    
    draw_transition(true);
  } 
  // ------------------------------------------------------------
  // GAME
  // ------------------------------------------------------------
  else if (state == State.GAME) {
    introSong.stop();
    
    // Provjeri kolizije.
    for (Player player : players) {
      if (player.spearActive)
        ballSpearCollision();
    }
    
    ballPlayerCollision();
    ballTopEdgeCollision();
    
    // Ažuriraj kugle i igrače.
    for (Ball ball : balls)
      ball.update();
    for (Player player: players)
      player.update();
    
    // Ponovno iscrtaj pozadinu.
    background(menuBackground);
    rect((windowWidth - gameWidth)/2, 0, gameWidth, gameHeight);
  
    // Nacrtaj igrače i lopte.
    for (Player player: players)
      if (player.lives > 0 || player.just_lost_life) player.draw();
    for (Ball ball : balls)
      ball.draw();
         
    // Trenutno će koplje "izlaziti" iz okvira igre pa treba još
    // jednom iscrtati dio pozadine.
    image(menuBackgroundSmall, 0, gameHeight);
    
    // Ispis preostalih života, ovo će vjerojatno biti sličice kasnije.
    /*fill(255);
    textFont(gameFont);
    textAlign(CENTER, CENTER);
    int j = 0;
    for (Player player : players) {
      if (player.lives >= 0) text("Player " + (j+1) + ":  " + player.lives, 225*j+100, windowHeight-20 );
      else text("Player " + (j+1) + ":  0", 225*j+100, windowHeight-20 );
      j++;
    }*/
    
    //Ubacivanje slicica na kojima pise Player1, Player2
    image(player1_text, (windowWidth - gameWidth)/2, windowHeight - 40 - 42);
    image(player2_text, windowWidth - (windowWidth-gameWidth)/2 - 175, windowHeight - 40 - 40);
    stroke(150);
    strokeWeight(4);
    fill(194,194,193);
    rect((windowWidth-gameWidth)/2 + player1_text.width + 5, windowHeight - 40 - 42 + 5, 120, 35);
    rect(windowWidth - (windowWidth-gameWidth)/2 - 175 - 120 - 8, windowHeight - 40 - 40 + 2, 122, 37);
    if(players.size() == 2) {
       //onda se ispisuje tekst u score drugog igraca, inace samo score prvog igraca
    }
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
             image(lives, (windowWidth - gameWidth)/2, windowHeight - 82 - 30 - 5);
             text(player.points, (windowWidth-gameWidth)/2 + player1_text.width + 80, windowHeight - 58);
           } else {
             image(lives, windowWidth - (windowWidth-gameWidth)/2 - 306, windowHeight - 82 - 30 - 5);
             text(player.points, windowWidth - (windowWidth-gameWidth)/2 - 175 - 50, windowHeight - 58);
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
        image(lives, windowWidth - (windowWidth-gameWidth)/2 - 306, windowHeight - 82 - 30 - 5) ;
      } catch (Exception e) {
        print("Slika ne postoji");
      }
    }
    
    //Ispis levela i baklji
    image(level1, windowWidth/2 - 124/2, windowHeight - 30 - 91);
    image(torch, windowWidth/2 - 124/2 - 50 - 33, gameHeight + (windowHeight - gameHeight)/2 - 118/2);
    image(torch, windowWidth/2 + 124/2 + 50, gameHeight + (windowHeight - gameHeight)/2 - 118/2);
    
    
    
   
    draw_transition(true); // Crtanje zidova koji se pomiču
     
    // dodati neki delay igre?
    // Ako je igrač izgubio život, ali još uvijek ima preostale živote:
    if(lostLife && !is_game_over) {
      // Pišemo prikladni tekst za kratak period vremena:
      if (millis() - delay_millisecs <= 500)
        write_dummy_text("OUCH");
      else {
        lostLife = false;
        // Nakon tog vremena, ponovno postavimo pozicije igrača.
        for (Player player_: players){
          player_.resetPosition();
          player_.resetOrientation();
          player_.resetState();
        }
        // Ponovno postavljamo kugle.
        balls.clear();
        balls.add(new Ball(windowWidth/2, gameHeight/2, 4));
        // Ponovno postavljamo bodove
        // ------------- TODO: prilagoditi između levela (jer se zbrajaju bodovi za sve levele)----------
        // ------------------- Vjv će biti ok dodati varijablu player.overall_points gdje ćemo nadodavati bodove iz levela
        // ------------------- varijabla player.points će onda biti preimenovana u player.level_points
        for (Player player : players) player.points = 0;
        // Ponovno pokrećemo vrijeme:
        minutes = minute();
        seconds = second();
        // Naznačimo da je sad trenutak kad se igrač treba spremati za ponovni početak igre.
        get_ready = true;
        getReady_millisecs = millis();
        // I ponovno 'pauziramo' igru (tj zaustavimo nove loptice).
        pause_game();
      }
     }
     
     if(get_ready) {
       for (Player player: players) player.just_lost_life = false;
       // Opet određeni kratki interval upozravamo igrača da se spremi za novi pokušaj.
       if (millis() - getReady_millisecs <= 500)
        write_dummy_text("GET READY");
       else {
         // Nakon tog vremena, ponovno pokrenemo lopte.
         get_ready = false;
         restart_the_balls();
       }
     }
    
    // Ako je igra gotova, pišemo odgovarajuću poruku:
    if(is_game_over) {
      write_dummy_text("GAME OVER");
      if(isEnter) {
        reset_game();
        isEnter = false;
      }
    }
    
    // Ako je level pobjeđen, prikazuje se odgovarajuća poruka:
    if (level_done) {
      write_dummy_text("Level passed " + players.get(0).points);
      if(isEnter) {
        reset_game();
        isEnter = false;
      }
    }
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

void mousePressed(){ 
  
  //Provjeravamo je li korisnik kliknuo na mute button
  if ((mouseX >= (windowWidth - 80-20) && mouseX <= (windowWidth - 80 + 20)) && (mouseY >= 25 && mouseY <= 55) && state == State.MAINMENU){
    
    if(soundOn) {
     soundOn = false;
     introSong.stop(); 
    }
    else {
     soundOn = true;
     introSong.loop();
    }
  }
  
  if((mouseX >= (windowWidth/2 - 80))  && (mouseX <= (windowWidth/2 + 80)) && (mouseY >= (5*windowHeight/6 - 45)) && (mouseY <= (5*windowHeight/6 + 45)) && state == State.INSTRUCTIONS) {
    reset_game();
  }
}

void setMove(int k, boolean b) {
  // Standardne left-right tipke za prvog igrača.
  // Ako je igra gotova ili je tama izgubljen život ili mso u get-ready fazi,
  // ne želimo da se igrači mogu i dalje micati. Isto vrijedi i ako trenutno
  // nismo u igri (lijevo-desno se ne koristi u meniju).
  switch (k) {
  case LEFT:
    if (is_game_over || lostLife || get_ready || level_done || state != State.GAME) return;
    isLeft = b;
    if (b)
      players.get(0).orientation = PlayerOrientation.LEFT;
    else
      players.get(0).orientation = PlayerOrientation.BACK;
    return;

  case RIGHT:
    if (is_game_over || lostLife || get_ready || level_done || state != State.GAME) return;
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

// Funkcija koja obrađuje kraj (pobjedu) levela:
void levelWon() {
  level_done = true;
  pause_game();
  int seconds_passed = second() - seconds;
  int minutes_passed = minute() - minutes;
  if (seconds_passed < 0) seconds_passed += 60;
  if (minutes_passed < 0) minutes_passed += 60;
  for (Player player : players) {
    player.points += (60-seconds_passed)*5;
  }
  if(soundOn)
    levelDoneSound.play();
  
}

// Funkcija za detekciju kolizije lopti i koplja.
void ballSpearCollision() {
  // Za svakog igrača (prva for petlja) i svaku loptu (druga for petlja)
  // gledamo dolazi li do kolizije i potom postupamo prikladno.
  for (Player player : players) {
    for (int i = balls.size() - 1; i >= 0; --i)
      if (balls.get(i).checkSpearCollision(player.xSpear, player.ySpear))
        splitBall(i, player);
    //-------------------------
    // STARI KOD (za svaki slučaj). Sve unutar petlje je prebačeno u funkciju splitBall(), ali može se vratiti za 
    // slučaj da nešto ne radi kako treba. Petlja (gore) je napisana tako da ide unatrag
    // da ne bi došlo kod problema prilikom balls.remove(i) unutar splitBall().
    //-------------------------
    /*for (int i = 0; i < balls.size(); ++i) {
      if (balls.get(i).checkSpearCollision(player.xSpear, player.ySpear)) {
        player.points += (6-balls.get(i).sizeLevel+1)*10;
        print(player.points, "\n");
        player.resetSpear();
        if (balls.get(i).sizeLevel > 1) {
          if(soundOn) {
            player.stopSpearSound(); //prestaje reprodukcija zvuka strelice
            collisionSound.play(); //reproduciramo zvuk pogotka
          }
                    
          balls.add(new Ball(balls.get(i).xCenter, balls.get(i).yCenter, balls.get(i).sizeLevel-1, 1, -3, balls.get(i).yCenter, player.no_player));
          balls.add(new Ball(balls.get(i).xCenter, balls.get(i).yCenter, balls.get(i).sizeLevel-1, -1, -3, balls.get(i).yCenter, player.no_player));
        }
        balls.remove(i);
        if (balls.isEmpty()) levelWon();
        return;
      }
    }*/
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
  isLeft = false; isRight = false; isSpace = false;
  isA = false; isS = false; isD = false;
}

// Funkcija koja prikazuje završni rezultat i preusmjerava na main menu:
void game_over() {
  is_game_over = true;
  pause_game();
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
    // Razdvoji je ako je udarila u gornji rub.
    if (ball.yCenter - ball.radius <= 0)
      splitBall(i, players.get(ball.hitByPlayer - 1));
  }  
}

// Funkcija koja se brine o razdvajanju i-te lopte u dvije te
// pridodaje bodove igraču player.
void splitBall(int i, Player player) {
  Ball ball = balls.get(i);
  
  player.points += (6-ball.sizeLevel+1)*10;
  print(player.points, "\n");
  player.resetSpear();
  if (ball.sizeLevel > 1) {
    if(soundOn) {
      player.stopSpearSound(); //prestaje reprodukcija zvuka strelice
      collisionSound.play(); //reproduciramo zvuk pogotka
    }
    balls.add(new Ball(ball.xCenter, ball.yCenter, 
                      ball.sizeLevel-1, 1, -3, 
                      ball.yCenter, player.no_player));
                      
    balls.add(new Ball(ball.xCenter, ball.yCenter, 
                      ball.sizeLevel-1, -1, -3, 
                      ball.yCenter, player.no_player));
  }
  balls.remove(i);
  if (balls.isEmpty()) levelWon();
  return;
}
