renv::restore()
lockfile <- "https://raw.githubusercontent.com/carpentries/workbench-template-rmd/f6ea6bca196ecd127d4e550afa6e940513419d1c/renv/profiles/lesson-requirements/renv.lock"
if (dir.exists("test")) {
  unlink("test", recursive = TRUE, force = TRUE)
}

dir.create("test")
# download.file(lockfile, "test/renv.lock")
file.copy("../test-lock.json", "test/renv.lock")

callr::r(function() {
  setwd("test")
  proj <- getwd()
  renv::init(project = proj, restart = FALSE)
  renv::deactivate(project = proj)
}, show = TRUE, user_profile = FALSE)

writeLines("library(reprex)", "test/test.R")

callr::r(function() {
  setwd("test")
  print(renv_lib <- renv::paths$library(project = getwd()))
  print(renv_lock <- renv::paths$lockfile(project = getwd()))
  installed <- utils::installed.packages(lib.loc = renv_lib)[, "Package"]
  deps <- unique(renv::dependencies(path = getwd(), root = getwd(), dev = TRUE)$Package)
  pkgs <- setdiff(deps, installed)
  print(.libPaths())
  # hydrate
  hydra <- renv::hydrate(packages = pkgs, library = renv_lib,
    update = FALSE, sources = .libPaths())
  renv::restore(library = renv_lib, lockfile = renv_lock, prompt = FALSE)
  renv::load(project = getwd())
  renv::snapshot(lockfile = renv_lock, prompt = FALSE)
  renv::diagnostics(project = getwd())
  renv::deactivate(project = getwd())
}, show = TRUE, user_profile = FALSE)

