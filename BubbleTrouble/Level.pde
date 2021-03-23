// Klasa koja predstavlja razine igre.
class Level{
  
  int number;
  // boja pozadine levela
  int r, g, b;
  ArrayList<Ball> balls = new ArrayList<Ball>(); 
  float ballXVelocity, ballYVelocity;
  int time;
    
  Level(int number){
    switch (number){
      case 1:
        number = 1;
        r = 155;
        g = 225;
        b = 247;        
        ballXVelocity = 1;
        ballYVelocity = 2;
        
        time = 45000;
        
        balls.add(new Ball((windowWidth-gameWidth)/2 + 100, gameHeight/2, 2, ballXVelocity, ballYVelocity));    
        return;
      
      case 2:
        number = 2;
        r = 245;
        g = 254;
        b = 210;
        ballXVelocity = 1;
        ballYVelocity = 3;
        
        time = 60000;
        
        balls.add(new Ball(windowWidth/2, gameHeight/2 - 50, 3));
        return;
      
      case 3:
        number = 3;   
        r = 0;
        g = 157;
        b = 16;        
        ballXVelocity = 1;
        ballYVelocity = 2;
        
        time = 90000;
        
        balls.add(new Ball((windowWidth-gameWidth)/2 + 10, gameHeight - 10, 1, ballXVelocity, ballYVelocity));   
        balls.add(new Ball((windowWidth-gameWidth)/2 + 100, gameHeight - 110, 1, ballXVelocity, ballYVelocity));   
        balls.add(new Ball((windowWidth-gameWidth)/2 + 190, gameHeight - 10, 1, ballXVelocity, ballYVelocity));  
        balls.add(new Ball((windowWidth-gameWidth)/2 + 280, gameHeight - 110, 1, ballXVelocity, ballYVelocity));  
        
        balls.add(new Ball((windowWidth-gameWidth)/2 + gameWidth - 10, gameHeight - 110, 1, ballXVelocity, ballYVelocity));   
        balls.add(new Ball((windowWidth-gameWidth)/2 + gameWidth - 100, gameHeight - 10, 1, ballXVelocity, ballYVelocity));   
        balls.add(new Ball((windowWidth-gameWidth)/2 + gameWidth - 190, gameHeight - 110, 1, ballXVelocity, ballYVelocity));  
        balls.add(new Ball((windowWidth-gameWidth)/2 + gameWidth - 280, gameHeight - 10, 1, ballXVelocity, ballYVelocity));
        return;
      
      case 4: 
        number = 4;
        r = 155;
        g = 0;
        b = 255;
        ballXVelocity = 1;
        ballYVelocity = 3.2;
        
        time = 120000;
        
        balls.add(new Ball((windowWidth-gameWidth)/2 + 60, gameHeight/2, 5, ballXVelocity, ballYVelocity)); 
        balls.add(new Ball((windowWidth-gameWidth)/2 + gameWidth - 60, 2*gameHeight/3, 4, ballXVelocity, ballYVelocity)); 
        return;
      
      case 5:   
        number = 5;
        r = 135;
        g = 255;
        b = 210;
        ballXVelocity = 1.2;
        ballYVelocity = 3.5;
        
        time = 150000;
        
        balls.add(new Ball((windowWidth-gameWidth)/2 + 80, gameHeight/2 - 60, 6, ballXVelocity, ballYVelocity)); 
        return;     
    }    
  }
}
