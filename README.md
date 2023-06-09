# Working example for renv issue 1177

Yes, this is NOT exactly minimal, but I've gotten the setup as minimal as I can
given the circumstances and I _am_ able to get the same results as I observe.

This demonstrates how a {renv} project controlled from another {renv} project
could fail to detect and install new packages in renv 0.17.2. 

## Setup

There are two folders: `renv-16` and `renv-17` corresponding to projects that
use renv versions 0.16.0 and 0.17.2, respectively. 

```sh
renv-1{6,7}
├── .renvignore
├── .Rprofile
├── lockfile
├── out.txt
├── renv
│   ├── activate.R
│   ├── library
│   ├── sandbox
│   ├── settings.json
│   └── staging
├── renv-16.txt
├── renv.lock
├── script.R
└── test
    ├── renv
    ├── renv.lock
    └── test.R
```

The folder structure is designed so that each will attempt to control the same
test project that attempts to add the {reprex} package to [an existing
lockfile](https://raw.githubusercontent.com/carpentries/workbench-template-rmd/f6ea6bca196ecd127d4e550afa6e940513419d1c/renv/profiles/lesson-requirements/renv.lock)
(in the `test/` directory).

All the files are identical except for the following:

| file | renv version |
|------|--------------|
| [`renv-16/renv.lock`](renv-16/renv.lock) | 0.16.0 |
| [`renv-17/renv.lock`](renv-17/renv.lock) | 0.17.2 |


INSIDE of each project, is a script called [`script.R`](renv-16/script.R), which
will do the following:

1. remove and re-create the test directory with a [`renv.lock` file](https://raw.githubusercontent.com/carpentries/workbench-template-rmd/f6ea6bca196ecd127d4e550afa6e940513419d1c/renv/profiles/lesson-requirements/renv.lock) that is tuned to rendering R Markdown documents
2. initialize the project **from callr**
3. add a test file that contains `library('reprex')`
4. run hydrate + restore + snapshot **from callr** in that test directory

This demonstrates that this process works in renv 0.16.0, but it does not do
so in renv 0.17.2

## Findings

### Output

Compare the [renv version 0.16.0 output](renv-16/out.txt) with 
[renv version 0.17.2 output](renv-17/out.txt).

### Library structure

The renv libraries are treated _slightly_ differently after the runthrough.

Interestingly enough: the renv libraries in the `renv-1{6,7}/test/renv/library`
directories **both contain the correct packages**.


However, we find that `renv-16/renv/library` contains _all_ the packages needed
for reprex, and `renv-17/renv/library` still contains the original packages for
this example. 

## Reproducing

to reproduce, use `run.sh`

```bash
bash run.sh
```

This will enter into each directory, restore the renv project from the lockfile,
and then run the script (which is identical for both projects). 
