

float[] getActivity(float arr[][][], int i, int j, int k, int nx, int ny, int nz) {
  int ir = pbc(i+1, nx);
  int il = pbc(i-1, nx);
  int ju = pbc(j+1, ny);
  int jd = pbc(j-1, ny);
  int kf = pbc(k+1, nz);
  int kb = pbc(k-1, nz);

  // calculate the activity in the von neumann environment 
  float A1 = 0;                             // nearest neighbors
  A1 += arr[ir][j][k]+arr[il][j][k];      // x
  A1 += arr[i][ju][k]+arr[i][jd][k];      // y
  A1 += arr[i][j][kf]+arr[i][j][kb];      // z

  // calculate the activity in the moore environment 
  float A2 = 0;                             // next nearest     
  A2 += arr[i][ju][kb]+arr[i][jd][kb];    // k--
  A2 += arr[il][j][kb]+arr[ir][j][kb]; 
  A2 += arr[ir][ju][k]+arr[ir][jd][k];    // k
  A2 += arr[il][ju][k]+arr[il][jd][k]; 
  A2 += arr[i][ju][kf]+arr[i][jd][kf];    // k++
  A2 += arr[il][j][kf]+arr[ir][j][kf];
  
  return new float[]{A1, A2};
}




// periodic boudnary conditions
int pbc(int i, int n) {
  return (i+n)%n;
}
