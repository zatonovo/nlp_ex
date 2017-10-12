library(futile.logger)
library(lambda.tools)


viterbi <- function(oi,q,a,b, aif=1) {
  is <- get_state_index(q)
  fwd <- matrix(0, nrow=length(q)+2, ncol=length(oi))
  bt <- matrix(0, nrow=length(q)+2, ncol=length(oi))

  # Initialization step
  fwd[is,1] <- a[1,is] * b[oi[1],is-1]
  flog.debug("Initialize fwd:",fwd, capture=TRUE)

  # Recursion step
  out <- fold(2:length(oi), function(t,acc.o) {
    fold(is, function(i,acc.i) {
      fwd <- acc.i$fwd
      bt <- acc.i$bt
      flog.debug(sprintf("[%s,%s] product of:",i,t),
        cbind(fwd[-c(1,nrow(fwd)),t-1], a[-1,i], b[oi[t],i-1]), capture=TRUE)
      v <- fwd[-c(1,nrow(fwd)),t-1] * a[-1,i] * b[oi[t],i-1]
      fwd[i,t] <- max(v)
      bt[i,t] <- which(v == max(v))
      list(fwd=fwd,bt=bt)
    }, acc.o)
  }, list(fwd=fwd,bt=bt))

  fwd <- out$fwd
  bt <- out$bt
  flog.debug("Final fwd:",fwd, capture=TRUE)
  flog.debug("Final bt:",bt, capture=TRUE)

  # Termination
  if (length(aif) == 1) aif <- rep(aif,length(is))
  fwd.t <- as.numeric(max(fwd[-c(1,nrow(fwd)), ncol(fwd)] * aif))
  bt.t <- which(fwd.t == fwd[-c(1,nrow(fwd)), ncol(fwd)] * aif)
  list(fwd=fwd.t, bt=bt.t)
}

get_state_index <- function(q) {
  is <- 1 + 1:length(q)
  names(is) <- q
  is
}
