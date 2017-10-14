Sys.setenv(WNHOME='~/workspace/nlp_ex/data/dict')
library(lambda.r)
library(wordnet)


#' Get majority classes from a set of candidates
majority <- function(x) {
  labels < table(x)
  names(labels)[which.max(labels)]
}

#' @param ns A matrix of neighbor labels, one per row
#' @param ys The actual class label
#' @example
#' neighbors <- get_neighbors(m, 9)
#' pr <- ranked_pr(neighbors)
ranked_pr(ns) %:=% ranked_pr(ns[,-ncol(ns)], ns[,ncol(ns)])

ranked_pr(ns, ys) %:=% {
  rank_fn <- function(j) {
    labels <- ns[j,]
    actual <- ys[j]
    U <- sum(labels == actual)
    t(sapply(1:length(labels), function(i) {
      R <- sum(labels[1:i] == actual)
      p <- R / i
      r <- R / U
      c(i=i,p=p,r=r)
    }))
  }
  # Iterate over each neighbors and calculate precision and recall at each rank
  each <- do.call(rbind, lapply(1:nrow(ns), rank_fn))
  # Average
  p <- c(1,tapply(each[,2], each[,1], mean))
  r <- c(0,tapply(each[,3], each[,1], function(x) mean(x,na.rm=TRUE)))
  plot(cbind(r,p), xlim=c(0,1), ylim=c(0,1), type='l',
    xlab="Recall", ylab="Precision")
  text(cbind(r,p), labels=1:nrow(ns), pos=3)
}
