recoder_manquantes_en_zero <- function(x) {
  y <- ifelse(test = (x == "" | is.na(x)),
              yes = 0,
              no = x)
  y
}