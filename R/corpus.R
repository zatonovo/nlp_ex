#' Load Brown corpus
#'
#' @example
#' df <- load_brown('brown')
load_brown <- function(path) {
  ignore <- c('README','CONTENTS','cats.txt')
  fs <- list.files(path)
  fs <- fs[!fs %in% ignore]
  do.call(rbind, lapply(fs, function(f) load_brown_article(path,f)))
}

#' Load a single article from the Brown corpus
load_brown_article <- function(path,f) {
  old.opt <- options(stringsAsFactors=FALSE)
  on.exit(options(stringsAsFactors=old.opt[[1]]))

  flog.info("Work on %s/%s", path,f)
  x <- readLines(sprintf('%s/%s', path,f))
  x <- sub('^\\t','', x[nchar(x) > 0])
  s <- strsplit(x, '[ /]')
  do.call(rbind, lapply(1:length(s), function(i) {
    if (length(s[[i]]) %% 2 != 0) {
      flog.warn("Wrong string length (%s) for %s", length(s[[i]]), paste(s[[i]],collapse=' '))
      return(NULL)
    }
    m <- matrix(s[[i]], ncol=2, byrow=TRUE)
    colnames(m) <- c('token','pos')
    m <- rbind(c('<s>','<s>'), m, c('<e>','<e>'))
    cbind(data.frame(file=f,sentence=i), m)
  }))
}

