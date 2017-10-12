library(futile.logger)
library(lambda.r)
library(lambda.tools)

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
classify_label(x, m, dist=cosine) %:=% {
  n <- ncol(m) - 1
  d <- apply(m[,-x], 2, function(td) dist(m[,x], td))
  sim <- which.min(d)
  lab <- ifelse(sim > x, sim+1,sim)
  flog.info("Found most similar at column %s with distance %s",lab,d[sim])
  list(pred=m@label[lab], act=m@label[x])
}


plot_tsne(m) %:=% {
  m <- t(m)
  dup <- duplicated(m)
  lab <- as.factor(m@label[!dup])
  m1 <- m[!dup,]
  tsne <- Rtsne(m1)
  plot(tsne$Y, col=lab)
}
