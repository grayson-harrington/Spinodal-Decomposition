
// 2:1 ration works best for visuals.
int nx = 200;
int ny = 100;
int nz = 100;

float D = 0.6;
float A = 1.3;
// 0.16666666 was found to work the best for 2D
float cons = .095; // 0.095 was found to work the best for 3D
float low = -0.001;
float high = 0.001;

int step = 0;

float cellSize;
float[][][] curr, nextA, nextB;

float thetaX, thetaY;
float rspeed = 1;

int width3D;

int pos = 0; // loop from 0 -> nx-1
int modRate = 1; // lower = faster

void setup() {
  size(1200, 600, P3D);
  width3D = width/2;

  cellSize = width3D / (float)max(nx, ny, nz);
  curr = new float[nx][ny][nz];
  nextA = new float[nx][ny][nz];
  nextB = new float[nx][ny][nz];

  // init system 
  for (int i = 0; i < nx; i++) {
    for (int j = 0; j < ny; j++) {
      for (int k = 0; k < nz; k++) {
        curr[i][j][k] = map(random(0, 1), 0, 1, low, high);
      }
    }
  }

  //beware of pbc here. just don't go all the way to the edge.
  int x = nx/2;
  int y = ny/2;
  int z = nz/2;
  curr[x][y][z] = 1;
  curr[x][y+1][z] = 1;
  curr[x+1][y][z] = 1;
  curr[x+1][y+1][z] = 1;
  curr[x][y][z+1] = 1;
  curr[x][y+1][z+1] = 1;
  curr[x+1][y][z+1] = 1;
  curr[x+1][y+1][z+1] = 1;

  thetaX = -PI/5;
  thetaY = -PI/5;
}

void draw() {
  background(31);

  step++;
  println(step);
  if (step == 1201) {
    noLoop();
  }

  // next A
  for (int i = 0; i < nx; i++) {
    for (int j = 0; j < ny; j++) {
      for (int k = 0; k < nz; k++) {
        float[] act = getActivity(curr, i, j, k, nx, ny, nz);
        float A1 = act[0];
        float A2 = act[1];
        nextA[i][j][k] = (float)(A*Math.tanh(curr[i][j][k]) + D*(cons*(A1 + A2/2) - curr[i][j][k]));
      }
    }
  }

  // next B
  for (int i = 0; i < nx; i++) {
    for (int j = 0; j < ny; j++) {
      for (int k = 0; k < nz; k++) {
        float[] actA = getActivity(curr, i, j, k, nx, ny, nz);
        float A1 = actA[0];
        float A2 = actA[1];
        float[] actB = getActivity(nextA, i, j, k, nx, ny, nz);
        float B1 = actB[0];
        float B2 = actB[1];
        nextB[i][j][k] = nextA[i][j][k] - cons*(B1-A1) - cons*(B2-A2)/2;
      }
    }
  }

  // update and draw
  pushMatrix();
  translate(width3D/2-150, height/2, -width3D*1.5/3);
  rotateX(thetaX);
  rotateY(thetaY);

  int offx = -nx/2;
  int offy = -ny/2;
  int offz = -nz/2;

  pushMatrix();
  noStroke();
  fill(255, 255);
  rectMode(CENTER);
  translate(-width3D/2+pos*cellSize, 0, 0);
  rotateY(PI/2);
  int lip = 25;
  rect(cellSize/2, -cellSize/2, nz*cellSize+lip, ny*cellSize+lip);
  popMatrix();

  for (int i = 0; i < nx; i++) {
    for (int j = 0; j < ny; j++) {
      for (int k = 0; k < nz; k++) {
        curr[i][j][k] = nextB[i][j][k];

        color val = lerpColor(0, 255, (curr[i][j][k]+1)/2);
        fill(val, val);
        noStroke();
        pushMatrix();
        translate((i+offx)*cellSize, (j+offy)*cellSize, (k+offz)*cellSize);
        box(cellSize);
        popMatrix();
      }
    }
  }
  popMatrix();

  stroke(255);
  strokeWeight(2);
  line(width/2, 0, width/2, height);

  float newCellSize = cellSize*1.5;
  float off = width3D/2-ny*newCellSize/2;
  for (int k = 0; k < nz; k++) {
    for (int j = 0; j < ny; j++) {
      color val = lerpColor(0, 255, (curr[pos][j][k]+1)/2);
      fill(val, val);
      noStroke();
      rectMode(CORNER);
      rect(width3D+(nz-1-k)*newCellSize+off, j*newCellSize+off, newCellSize, newCellSize);
    }
  }

  if (step % modRate == 0) {
    pos++;
    if (pos > nx-1) {
      pos = 0;
    }
  }

  saveFrame("frames/"+nx+"."+ny+"."+nz+"_"+D+"_"+A+"_"+abs(low)+"_"+abs(high)+"_layers/####.png");
}
