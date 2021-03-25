// Klasa koja predstavlja razine igre.
class Level{
  
  int number;
  // boja pozadine levela
  int r, g, b;
  ArrayList<Ball> balls = new ArrayList<Ball>(); 
  // Niz stringova čuva naziv supermoći koja će (ako string nije prazan) ispasti 
  // iz prve udarene loptice veličine indexa niza + 2 (iz loptice razine 1 ne može ispasti supermoć).
  String[] superpowers = {"", "", "", "", ""};
  float ballXVelocity, ballYVelocity;
  int time;
    
  Level(int number){
    switch (number){
      case 1:
        number = 1;
        // plava
        r = 200;
        g = 250;
        b = 255;        
        ballXVelocity = 1;
        ballYVelocity = 2;
        
        time = 45000;
        
        balls.add(new Ball((windowWidth-gameWidth)/2 + 100, gameHeight/2, 2, ballXVelocity, ballYVelocity, BallColor.YELLOW));   

        return;
      
      case 2:
        number = 2;
        // žuta
        r = 245;
        g = 254;
        b = 210;
        ballXVelocity = 1;
        ballYVelocity = 3;
        
        time = 60000;
        
        balls.add(new Ball(windowWidth/2, gameHeight/2 - 50, 3, BallColor.GREEN));
        
        superpowers[1] = "life";
        return;
      
      case 3:
        number = 3;   
        // zelena
        r = 173;
        g = 235;
        b = 173;        
        ballXVelocity = 1;
        ballYVelocity = 2;
        
        time = 90000;
        
        balls.add(new Ball((windowWidth-gameWidth)/2 + 60, gameHeight - 20, 1, ballXVelocity, ballYVelocity, BallColor.BLUE));   
        balls.add(new Ball((windowWidth-gameWidth)/2 + 140, gameHeight - 200, 1, ballXVelocity, ballYVelocity, BallColor.PURPLE));   
        balls.add(new Ball((windowWidth-gameWidth)/2 + 220, gameHeight - 20, 1, ballXVelocity, ballYVelocity, BallColor.BLUE));  
        balls.add(new Ball((windowWidth-gameWidth)/2 + 300, gameHeight - 200, 1, ballXVelocity, ballYVelocity, BallColor.PURPLE));  
        
        balls.add(new Ball((windowWidth-gameWidth)/2 + gameWidth - 60, gameHeight - 20, 1, ballXVelocity, ballYVelocity, BallColor.BLUE));   
        balls.add(new Ball((windowWidth-gameWidth)/2 + gameWidth - 140, gameHeight - 200, 1, ballXVelocity, ballYVelocity, BallColor.PURPLE));   
        balls.add(new Ball((windowWidth-gameWidth)/2 + gameWidth - 220, gameHeight - 20, 1, ballXVelocity, ballYVelocity, BallColor.BLUE));  
        balls.add(new Ball((windowWidth-gameWidth)/2 + gameWidth - 300, gameHeight - 200, 1, ballXVelocity, ballYVelocity, BallColor.PURPLE));
        
        return;
      
      case 4: 
        number = 4;
        // ljubičasta
        r = 209;
        g = 179;
        b = 255;
        ballXVelocity = 1;
        ballYVelocity = 3.2;
        
        time = 120000;
        
        balls.add(new Ball((windowWidth-gameWidth)/2 + 60, gameHeight/2, 4, ballXVelocity, ballYVelocity, BallColor.ORANGE)); 
        balls.add(new Ball((windowWidth-gameWidth)/2 + gameWidth - 60, 2*gameHeight/3, 3, ballXVelocity, ballYVelocity, BallColor.YELLOW)); 

        superpowers[2] = "shield";
        
        return;
      
      case 5:   
        number = 5;
        r = 210;
        g = 224;
        b =224243;
        ballXVelocity = 1.2;
        ballYVelocity = 3.5;
        
        time = 150000;
        
        balls.add(new Ball((windowWidth-gameWidth)/2 + 80, gameHeight/2 - 150, 5, ballXVelocity, ballYVelocity, BallColor.PURPLE)); 
        balls.add(new Ball((windowWidth-gameWidth)/2 + 150, gameHeight/2 - 200, 4, ballXVelocity, ballYVelocity, BallColor.YELLOW));
        
        superpowers[4] = "life";
        superpowers[1] = "shield";
        superpowers[0] = "shield";
        
        return;     
    }    
  }
}
