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

//slike u MAINMENU
PImage character, bubbleTrouble, redBall, torch, soundOnImg, soundOffImg;
PFont menuFont;
PFont gameFont;

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
  soundOnImg = loadImage("soundOn.png");
  soundOffImg = loadImage("soundOff.png");
  
  //učitavanje fonta za MAINMENU
  menuFont = loadFont("GoudyStout-28.vlw");
  
  //učitavanje fonta za GAME
  gameFont = loadFont("GoudyStout-16.vlw");
  
  path = sketchPath("");
  introSong = new SoundFile(this, path + "intro.mp3");
  shootingSound = new SoundFile(this, path + "shooting.mp3");
  collisionSound = new SoundFile(this, path + "collision.mp3");
  switchSound = new SoundFile(this, path + "switch.mp3");
  punchSound = new SoundFile(this, path + "punch.mp3");
  introSong.play();
  
}

void createPlayers() {
   // Ovisno o postavljenom broju igrača, popunjavamo listu i podešavamo početne pozicije
  for (int i = 0; i < quantity; i++)
    players.add(new Player((i+1)*windowWidth/(quantity+1)-25, i+1));
    ellipseMode(RADIUS); // Crtanje kružnica kao (srediste.x, srediste.y, radijus).
}

void draw() {
  if (state == State.MAINMENU) {   
    // pushStyle() i popStyle() za očuvanje trenutnog stila i naknadno vraćanje istog
    pushStyle();
    // Pozadina - neka siva boja
    background(190, 190, 190);
    
    // Crtanje vodoravnih i vertikalnih linija na pozadini (cigle) - treba još uljepšati
    int horizontalLines = 9;
    int verticalLines = 8;
    stroke(226, 226, 226);
    for (int i = 1; i < horizontalLines; i++) {
      line(0, i*windowHeight/horizontalLines, windowWidth, i*windowHeight/horizontalLines);
    }
    for (int i = 1; i < verticalLines; i++) {
      line(i*windowWidth/verticalLines, 0, i * windowWidth/verticalLines, windowHeight);
    }
       
    // Dodavanje lika, crvene kugle i baklji
    imageMode(CENTER);
    image(character, 2*windowWidth/3, windowHeight/2);
    image(redBall, windowWidth/4, windowHeight/4);
    image(torch, windowWidth/11 , windowHeight/2);
    image(torch, windowWidth/2.46, windowHeight/2);
    
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
    
    // Pritisak gumba Enter
    if (isEnter) {
      if(soundOn) switchSound.play(); 
      if (menuPick == MenuPick.ONEPLAYER) {
        quantity = 1;
        createPlayers();
        state = State.GAME;
      }
      else if (menuPick == MenuPick.TWOPLAYERS) {
        quantity = 2;
        createPlayers();
        state = State.GAME;
      }
      else if (menuPick == MenuPick.CONTROLS) state = State.INSTRUCTIONS;
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
    
    
  }else if (state == State.INSTRUCTIONS) {
    // TODO: Instructions.
    introSong.stop();
  } else if (state == State.GAME) {
     if(lostLife) {
       delay(500);
       lostLife = false;
     }
    introSong.stop();
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

void mousePressed(){ 
  
  //Provjeravamo je li korisnik kliknuo na mute button
  if ((mouseX >= (windowWidth - 80-20) && mouseX <= (windowWidth - 80 + 20)) && (mouseY >= 25 && mouseY <= 55)){
    
    if(soundOn) {
     soundOn = false;
     introSong.pause(); 
    }
    else {
     soundOn = true;
     introSong.play();
    }
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
          if(soundOn) {
            player.stopSpearSound(); //prestaje reprodukcija zvuka strelice
            collisionSound.play(); //reproduciramo zvuk pogotka
          }
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
          if(soundOn) {
            player.stopSpearSound();
            punchSound.play();
          }
          // Ako je kolizija tek počela, postavljamo atribut na true.
          // Ovime izbjegavao da se odjednom oduzme nekoliko života umjesto jednog.
          current.is_being_hit = true;
          player.spearActive = false; //maknemo i strelice od tog igrača
          lostLife = true;
          
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
