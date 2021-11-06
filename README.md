## Install instructions

The default Ubuntu 20.04 (AMI `ami-09d9c897fc36713bf`) image was used for both the `c6g` as well as the `c5` instance.

### Step 1: Install Linux dependencies

```
sudo apt update
sudo apt install r-base-core
```

### Step 2: Install CmdStanR and CmdStan

```r
install.packages("remotes") # yes on both command-line prompts
remotes::install_github("stan-dev/cmdstanr")
```
