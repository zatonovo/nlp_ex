library(futile.logger)
library(lambda.r)
library(lambda.tools)
library(Rtsne)

#' Tokenize input strings
tokenize <- function(x, xform=tolower) {
  x <- gsub('’',"'", xform(x), fixed=TRUE)
  x <- gsub('[“”"]','',x)
  x <- gsub("([,.]|'s|n't)", " \\1 ", x)
  s <- strsplit(x, '[[:space:]]')
  lapply(s, function(x) x[nchar(x) > 0])
}

trim <- function(x) {
  gsub('^[;[:space:]]+','', gsub('[;[:space:]]$','',x))
}


##############################################################################


#' Make term document matrix with raw counts
#' @param tk A list of tokens, one vector per document
term_document <- function(tk) {
  terms <- unique(do.call(c, tk))
  m <- matrix(0, nrow=length(terms), ncol=length(tk))
  rownames(m) <- terms
  lapply(1:length(tk), function(i) {
    freq <- table(tk[[i]])
    m[names(freq),i] <<- freq
  })
  m
}

#' Create term frequency - inverse document frequency matrix
tf_idf <- function(m) {
  df <- apply(m,1, function(r) length(which(r != 0)))
  idf <- log(ncol(m) / df)
  m * idf
}

cosine <- function(a,b) (a %*% b) / sqrt(a %*% a) / sqrt(b %*% b)
L1 <- function(a,b) sum((a-b))
L2 <- function(a,b) sqrt(sum((a-b)^2))


#' #examples
#' df <- read.csv('~/Downloads/fake_or_real_news.csv', stringsAsFactors=FALSE)
#' m <- build_model(df)
build_model(df, use.idf=TRUE) %:=% {
  tk <- tokenize(df$text)
  m <- term_document(tk)
  if (use.idf) m <- tf_idf(m)
  m@label <- df$label
  m
}

#' @param m term x doc
#' @examples
#' m <- build_model(df)
#' d <- classify_label(1, m, cosine)
classify_label <- function(x, m, n=1, dist=cosine) {
  d <- apply(m[,-x], 2, function(td) dist(m[,x], td))
  sim <- head(order(d, decreasing=TRUE), n)
  lab <- ifelse(sim > x, sim+1,sim)
  flog.debug("[%s] Found most similar at column %s with distance %s",x,lab,d[sim])
  c(pred=attr(m,'label')[lab], act=attr(m,'label')[x])
}

#' @examples
#' m <- build_model(df[1:200,])
#' ns <- get_neighbors(m)
get_neighbors <- function(m, n=5, ...) {
  t(sapply(1:ncol(m), function(i) classify_label(i,m,n, ...)))
}


#' @examples
#' m <- build_model(df[1:200,])
#' cm <- confusion_matrix(m)
confusion_matrix <- function(m, ...) {
  ds <- t(sapply(1:ncol(m), function(i) classify_label(i,m, ...)))
  table(ds[,1], ds[,2])
}


plot_tsne(m) %:=% {
  m <- t(m)
  dup <- duplicated(m)
  idx <- (1:nrow(m))[!dup]
  col <- as.factor(m@label[!dup])
  lab <- sprintf('%s:%s', idx,m@label[!dup])
  m1 <- m[!dup,]
  tsne <- Rtsne(m1)
  plot(tsne$Y, col=col)
  text(tsne$Y, labels=lab, pos=3, cex=.8)
}

