 //<>//
/*
 Iterative Closest Point ( ICP ) based on:
 https://nbviewer.jupyter.org/github/niosus/notebooks/blob/master/icp.ipynb
 "blocks" below as in Jupyter Nobeook page - Press any key to advance
 
 Anderson Sudario
 Jun, 2021
 */


PVector[] P, Q;
Plot plt = new Plot();
int block = 0;


PVector[] P_centered;
PVector center_of_P;
PVector[] Q_centered;
PVector center_of_Q;
Subplot ax;
int[] correspondences;
Tuple<float[][], int[]> cc;
double[][] R_found;
PVector t_found;
PVector[] P_corrected;


void setup() {
  size(600, 600);
  background(-1);
}


void draw() {
  //blocks as in Jupyter Nobeook page - Press any key to advance
  if (block == 0) {  //##############################################################################
    //GENERATE EXAMPLE DATA

    // initialize pertrubation rotation
    float angle = PI / 4.0;

    float[][] R_true = new float[][]{
      {cos(angle), -sin(angle)},
      {sin(angle), cos(angle)}
    };

    float[][] t_true = new float[][]{{-2}, {5}};

    // Generate data as a list of 2d points
    int num_points = 30;
    PVector[] true_data = new PVector[num_points];
    for (int i = 0; i < num_points; i++) {
      float y  = 0.2 * i * sin( 0.5 * i );
      true_data[i] = new PVector(i, y);
    }

    // Move the data
    PVector[] moved_data = new PVector[num_points];
    for (int i = 0; i < num_points; i++) {
      float x = PVector.dot ( true_data[i], new PVector( R_true[0][0], R_true[0][1] ));
      float y = PVector.dot ( true_data[i], new PVector( R_true[1][0], R_true[1][1] ));
      moved_data[i] = PVector.add( new PVector(x, y), new PVector(t_true[0][0], t_true[1][0]));
    }
    //R_true.dot(true_data) + t_true;

    //Assign to variables we use in formulas.
    Q = true_data;
    P = moved_data;

    plot_data(moved_data, true_data, "P: moved data", "Q: true data");
    plt.show();

    noLoop();
  } else if (block == 1) { //##############################################################################

    Tuple<PVector, PVector[]> tmp;
    
    tmp = center_data(P);
    center_of_P = tmp.x;
    P_centered = tmp.y;
    
    tmp = center_data(Q);
    center_of_Q = tmp.x;
    Q_centered = tmp.y;
    
    ax = plot_data(P_centered, Q_centered, "Moved data centered", "Moved data centered");

    plt.show();
    noLoop();
  } else if (block == 2) {  //##############################################################################


    //## COMPUTE CORRESPONDENCES

    correspondences = get_correspondence_indices(P_centered, Q_centered);
    ax = plot_data(P_centered, Q_centered, "P centered", "Q centered");
    draw_correspondeces(P_centered, Q_centered, correspondences, ax);

    plt.show();


    noLoop();
  } else if (block == 3) {  //##############################################################################

    cc= compute_cross_covariance(P_centered, Q_centered, correspondences);
    float[][]cov = cc.x;
    println(cov[0][0], cov[0][1], "\n"+ cov[1][0], cov[1][1] );
    noLoop();
  } else if (block == 4) {

    SingularValueDecomposition( cc.x );
    println(s);

    R_found = new double[2][2];
    R_found[0] = new double[]{ U[0][0] * V[0][0] + U[0][1] * V[1][0], U[0][0] * V[0][1] + U[0][1] * V[1][1] };
    R_found[1] = new double[]{ U[1][0] * V[0][0] + U[1][1] * V[1][0], U[1][0] * V[0][1] + U[1][1] * V[1][1] };
    
    t_found = PVector.sub( center_of_Q,  new PVector( new PVector( (float)R_found[0][0], (float)R_found[0][1] ).dot(center_of_P),
    new PVector( (float)R_found[1][0], (float)R_found[1][1] ).dot(center_of_P)));
    
    println("R_found =\n", R_found[0][0], R_found[0][1]+"\n"+R_found[1][0], R_found[1][1]);
    println("t_found =\n", t_found);

    noLoop();
  }else if (block == 5) {
    P_corrected = new PVector[P.length];
    for (int i = 0; i < P.length; i++) {
      P_corrected[i] = PVector.add( new PVector( new PVector( (float)R_found[0][0], (float)R_found[0][1] ).dot(P[i]),
                                                 new PVector( (float)R_found[1][0], (float)R_found[1][1] ).dot(P[i])) , t_found);
    }
    
    ax = plot_data(P_corrected, Q, "P corrected", "Q");
    plt.show();
    
    float[][] tmp = new float[P.length][2];
    for (int i = 0; i < P.length; i++) {
      PVector t = PVector.sub( P_corrected[i] , Q[i]);
      tmp[i] = new float[]{ t. x, t.y };
    }
    
    println("Squared diff: (P_corrected - Q) = ", normF( tmp ));

    noLoop();
  }else if (block == 6) {

    PVector[] values = icp_svd(P, Q, 3); //FOR THIS EXAMPLE, VALUES > 3 WILL RESULT IN WRONG SOLUTIONS
    ax = plot_data(values, Q, "P final", "Q");
    plt.show();
    
    
    float[][] tmp = new float[P.length][2];
    for (int i = 0; i < P.length; i++) {
      PVector t = PVector.sub( values[i] , Q[i]);
      tmp[i] = new float[]{ t.x, t.y };
    }
    println("Squared diff: (P_corrected - Q) = ", normF( tmp ));
    
    noLoop();
  }
}

void keyPressed() {
  block++;
  loop();
}
