

/*

 ####   CORRESPONDENCES COMPUTATION   ####
 
 */

//For each point in P find closest one in Q.
int[] get_correspondence_indices( PVector[] P, PVector[] Q ) {
  int p_size = P.length;
  int q_size = Q.length;
  int[] correspondences = new int[p_size];
  for ( int i = 0; i < p_size; i++) {
    PVector p_point = P[i];
    float min_dist = Float.MAX_VALUE;
    int chosen_idx = -1;
    for ( int j = 0; j < q_size; j++) {
      PVector q_point = Q[j];
      float dist = PVector.dist(p_point, q_point);
      if ( dist < min_dist) {
        min_dist = dist;
        chosen_idx = j;
      }
    }
    correspondences[i] = chosen_idx;
  }
  return correspondences;
}


void draw_correspondeces(PVector[] P, PVector[] Q, int[] correspondences, Subplot ax) {
  boolean label_added = false;

  for (int i = 0; i<correspondences.length; i++) {

    PVector[] xy =  { P[i], Q[correspondences[i]] };
    if ( !label_added ) {
      ax.plot( xy, 100, 8, "correspondences");
      label_added = true;
    } else {
      ax.plot( xy, 100, 8, "");
    }
  }
  ax.legend();
}






/*

 ####   MAKE DATA CENTERED   ####
 
 */


Tuple<PVector, PVector[]> center_data(PVector[] data) {
  return center_data(data, new int[]{});
}

Tuple<PVector, PVector[]>center_data(PVector[] data, int[] excluded_indices) {
  ArrayList<PVector>reduced_data = new ArrayList();
  ArrayList<Integer>ex_indices = new ArrayList(java.util.Arrays.asList(excluded_indices));
  for (int i = 0; i<data.length; i++) {
    if ( ex_indices.indexOf( i ) > -1 ) {
      continue;
    }
    reduced_data.add(data[i]);
  }

  PVector center = new PVector();

  for (int i = 0; i < reduced_data.size(); i++) {
    center = PVector.add(center, data[i]);
  }
  center.mult( 1./data.length );

  PVector[] ret = new PVector[reduced_data.size()];
  for (int i = 0; i < reduced_data.size(); i++) {
    ret[i] = PVector.sub( reduced_data.get(i), center);
  }

  return new Tuple(center, ret) ;
}





/*

 ####   COMPUTE CROSS COVARIANCE   ####
 
 */


Tuple<float[][], int[]> compute_cross_covariance(PVector[] P, PVector[] Q, int[] correspondences) {
  float[][] cov = new float[][]{{0, 0}, {0, 0}};
  ArrayList<Integer>exclude_indices = new ArrayList();
  for ( int i = 0; i < correspondences.length; i++) {
    PVector p_point = P[i];
    PVector q_point = Q[correspondences[i]];
    PVector diff = PVector.sub(p_point, q_point) ;
    float weight = kernel(1.0, new float[][]{{diff.x, diff.y}});
    if (weight < 0.01)exclude_indices.add(i);
    cov[0][0] += weight * p_point.x * q_point.x;
    cov[1][0] += weight * p_point.x * q_point.y;
    cov[0][1] += weight * p_point.y * q_point.x;
    cov[1][1] += weight * p_point.y * q_point.y;
  }

  int[] ret = new int[exclude_indices.size()];
  for (int i=0; i < ret.length; i++)
  {
    ret[i] = exclude_indices.get(i).intValue();
  }
  return new Tuple(cov, ret) ;
}


//Perform ICP using SVD
PVector[] icp_svd( PVector[] P, PVector[] Q, int iterations) {

  Tuple<PVector, PVector[]> tmp =  center_data(Q);
  center_of_Q = tmp.x;
  Q_centered = tmp.y;

  PVector[] P_copy = new PVector[P.length];
  arrayCopy(P, P_copy);

  int[] exclude_indices = new int[]{};

  for (int i = 0; i < iterations; i++) {
    tmp =  center_data(P_copy, exclude_indices);
    center_of_P = tmp.x;
    P_centered = tmp.y;
    correspondences = get_correspondence_indices(P_centered, Q_centered);

    cc= compute_cross_covariance(P_centered, Q_centered, correspondences);

    exclude_indices = cc.y;
    SingularValueDecomposition( cc.x );
    //R = U.dot(V_T)
    R_found = new double[2][2];
    R_found[0] = new double[]{ U[0][0] * V[0][0] + U[0][1] * V[1][0], U[0][0] * V[0][1] + U[0][1] * V[1][1] };
    R_found[1] = new double[]{ U[1][0] * V[0][0] + U[1][1] * V[1][0], U[1][0] * V[0][1] + U[1][1] * V[1][1] };

    t_found = PVector.sub( center_of_Q, new PVector( new PVector( (float)R_found[0][0], (float)R_found[0][1] ).dot(center_of_P),
      new PVector( (float)R_found[1][0], (float)R_found[1][1] ).dot(center_of_P)));

    for (int j = 0; j < P.length; j++) {
      P_copy[j] = PVector.add( new PVector( new PVector( (float)R_found[0][0], (float)R_found[0][1] ).dot(P_copy[j]),
        new PVector( (float)R_found[1][0], (float)R_found[1][1] ).dot(P_copy[j])), t_found);
    }

    println("iteration:", i);
  }
  return P_copy;
}

/*

 
 P_values = [P.copy()]
 P_copy = P.copy()
 corresp_values = []
 
 
 
 
 corresp_values.append(correspondences)
 norm_values.append(np.linalg.norm(P_centered - Q_centered))
 cov, exclude_indices = compute_cross_covariance(P_centered, Q_centered, correspondences, kernel)
 U, S, V_T = np.linalg.svd(cov)
 R = U.dot(V_T)
 t = center_of_Q - R.dot(center_of_P)
 P_copy = R.dot(P_copy) + t
 P_values.append(P_copy)
 corresp_values.append(corresp_values[-1])
 return P_values, norm_values, corresp_values
 */









float kernel(float threshold, float[][] error) {
  return (normF(error) < threshold)?0.:1.;
}


double normF (float[][] mat) {
  int m = mat.length;
  int n = mat[0].length;
  double f = 0;
  for (int i = 0; i < m; i++) {
    for (int j = 0; j < n; j++) {
      f = hypot(f, mat[i][j]);
    }
  }
  return f;
}
