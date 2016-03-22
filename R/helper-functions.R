# Helper functions =============================================================

# Install and load all packages provided from a character vector
load_pkgs = function(pkgs) {
  new_pkgs = pkgs[!(pkgs %in% installed.packages()[ , 'Package'])]
  if (length(new_pkgs) > 0) install.packages(new_pkgs)
  invisible(lapply(pkgs, function(x)
    suppressMessages(library(x, character.only = TRUE)))
  )
}
