import processing.javafx.*;

final int WIDTH = 256;
final int HEIGHT = 256;
final int SCALE = 4;


PGraphics canvas;

byte[] world;
boolean[] hasMoved;

final byte AIR = 0;
final byte ROCK = 1;
final byte SAND = 2;
final byte WATER = 3;
final byte TEST = 100;

byte right = -1;

byte brushSize = 5;
byte brush = 2;


void settings() {
  size(WIDTH*SCALE, HEIGHT*SCALE, P3D);
}

void setup(){
  canvas = createGraphics(WIDTH, HEIGHT);
  ((PGraphicsOpenGL)g).textureSampling(2);
  world = new byte[WIDTH*HEIGHT];
  hasMoved = new boolean[WIDTH*HEIGHT];
  restart();
  
  frameRate(60);
}

void restart(){
  for (int y=0; y<HEIGHT; ++y) {
    for (int x=0; x<WIDTH; ++x) {
      world[coords(x, y)] = AIR;

    }
  }
  int y = HEIGHT - 20;
  for (int x = 0; x < WIDTH ; ++x) {
    world[coords(x, y)] = ROCK;
  }
  int x = 20;
  for (y = 0; y < HEIGHT ; ++y) {
    world[coords(x, y)] = ROCK;
  }
  x = WIDTH - 20;
  for (y = 0; y < HEIGHT ; ++y) {
    world[coords(x, y)] = ROCK;
  }
}


void keyPressed(){
  switch (key){
    case '=': brushSize++; break;
    case '-': brushSize--; break;
    case '2': brush = SAND; break;
    case '3': brush = WATER; break;
    case 't': brush = TEST; break;
    case 'r': restart(); break;
  }
}

void draw() {
  changeDirection();
  cleanMoved();
  if (mousePressed) {
    int mouseXInWorld = mouseX / SCALE;
    int mouseYInWorld = mouseY / SCALE;
    paintArea(mouseXInWorld, mouseYInWorld, brush);
  }
  
  byte currentTile;
  
  for (int y=HEIGHT - 1; y > 0; y--) {
    for (int x=0; x<WIDTH; ++x) {
      if (hasMoved[coords(x, y)]){
       continue; 
      }
      currentTile = world[coords(x, y)];
      
      switch (currentTile) {
        case AIR: break;
        case SAND: updateSand(x,y); break;
        case WATER: updateWater(x, y); break;
        case TEST: updateTest(x, y); break;
      }
    }
  }
  
  
  
  
  canvas.beginDraw();
  canvas.loadPixels();
  for (int y=0; y<HEIGHT; ++y) {
    for (int x=0; x<WIDTH; ++x) {
      int currentCoords = coords(x,y);
      
      currentTile = world[currentCoords];
      color c = color(0,0,0);
            
      switch (currentTile) {
        case AIR: c = color(0,0,0); break;
        case ROCK: c = color(128,128,128); break;
        case WATER: c = color(0,0,255); break;
        case SAND: c = color(255,255,0); break;
        case TEST: c = color(255,0,0); break;
      }
      
      canvas.pixels[currentCoords] = c;
    }
  }
  canvas.updatePixels();
  canvas.endDraw();
  
  scale(SCALE);
  image(canvas, 0, 0);
}




int coords(int x, int y) {
   return x + WIDTH*y; 
}




void paintArea(int x, int y, byte c) {
  world[coords(x, y)] = c;
  for (int i = 1; i <= brushSize; i++){
    world[coords(x+i, y)] = c;
    world[coords(x-i, y)] = c;
    world[coords(x, y+i)] = c;
    world[coords(x, y-i)] = c;
    
    world[coords(x+i, y+i)] = c;
    world[coords(x-i, y-i)] = c;
    world[coords(x+i, y-i)] = c;
    world[coords(x-i, y+i)] = c;
  }
}


void cleanMoved(){
  for (int y=HEIGHT - 1; y > 0; y--) {
    for (int x=0; x<WIDTH; ++x) {
      hasMoved[coords(x, y)] = false;
    }
  }
}




void swap(int xOne, int yOne, int xTwo, int yTwo) {
  byte c = world[coords(xTwo, yTwo)];
  world[coords(xTwo, yTwo)] = world[coords(xOne, yOne)];
  world[coords(xOne, yOne)] = c;
  if (world[coords(xOne, yOne)] != AIR) {
    hasMoved[coords(xOne,yOne)] = true;
  }
  if (world[coords(xTwo, yTwo)] != AIR){ 
    hasMoved[coords(xTwo, yTwo)] = true;
  }
  return;
}




void changeDirection(){
  if (right == -1) {
    right = 1;
  }else {
    right = -1;
  }
}


void updateSand(int x, int y){
  if (world[coords(x, y + 1)] == AIR) {
    swap(x, y, x, y + 1);
  }
  else if (world[coords(x + right, y + 1)] == AIR) {
    swap(x, y, x + right, y + 1);
  }
}

void updateWater(int x, int y){
  if (world[coords(x, y + 1)] == AIR) {
    swap(x, y, x, y + 1);
    return;
  }
  else if (world[coords(x, y - 1)] == SAND){
    swap(x, y, x, y - 1);
    return;
  }
  else if (world[coords(x + 1, y + 1)] == AIR) {
    swap(x, y, x + 1, y + 1);
    return;
  }else if (world[coords(x - 1, y + 1)] == AIR) {
    swap(x, y, x - 1, y + 1);
    return;
  }
  else if (world[coords(x + 1, y)] == AIR){
    swap(x, y, x + 1, y);
    return;
  }else if (world[coords(x - 1, y)] == AIR){
    swap(x, y, x - 1, y);
    return;
  }
}


void updateTest(int x, int y) {
  swap(x,y,x+right,y);
}
