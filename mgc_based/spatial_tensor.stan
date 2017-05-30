data {
  int<lower=1> N;
  int<lower=1> m;
  int<lower=1> d;
  int y[N,N,m];
  matrix[N,3] X;
  real lambda1;
  real lambda2;
}
parameters {
  matrix[N,d] U;
  real eta[d,m];
  // matrix[N,N] Z;
  real<lower=0> tau[d];
  real<lower=0> phi1;
}

model {

    matrix[N,N] UDU;

    for(l in 1:m){
      UDU = U * diag_matrix(to_vector(eta[:,l])) * U'; // + Z;
      for(i in 1:N){
        // for(j in 1:(i-1)){
          target += bernoulli_logit_lpmf(y[i,:,l] | to_vector(UDU[i,:]));
        // }
      }
    }
    
    
    for(i in 1:d){
      target +=  normal_lpdf(to_vector(eta[i,:]) | 0, sqrt(tau[i]));
      target +=  gamma_lpdf( 1.0/tau[i] | 2, 1);
    }

    //variance for the factors
    target +=  normal_lpdf( to_vector(U) | to_vector(X), sqrt(phi1));
    target +=  gamma_lpdf( 1.0/phi1 | 2,1);

}
