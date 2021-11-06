## Install instructions

Ubuntu 20.04 images were used for both the `c6g` as well as the `c5` instance.

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