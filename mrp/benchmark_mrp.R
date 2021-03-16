library(cmdstanr)
library(rjson)

data = fromJSON(file = "mrp_all_ref.json")

mod0 <- cmdstan_model("mrp_ref.stan")
mod1 <- cmdstan_model("mrp_ref.stan", cpp_options = list(stan_threads = TRUE))
mod2 <- cmdstan_model("mrp_ref2.stan", cpp_options = list(stan_threads = TRUE, stan_cpp_optims = TRUE))

single <- c()
multi <- c()
optim <- c()
single_neff <- c()
multi_neff <- c()
optim_neff <- c()
seeds <- c(1,2,3,4,5)
for (seed in seeds) {
  fit0 <- mod0$sample(data,
                           seed = seed,
                           chains = 4,
                           parallel_chains = 4)
  
  fit1 <- mod1$sample(data,
                           chains = 4,
                           seed = seed,
                           parallel_chains = 4,
                           threads_per_chain = 8)
  
  fit2 <- mod2$sample(data,
                           chains = 4,
                           seed = seed,
                           parallel_chains = 4,
                           threads_per_chain = 8)
  
  single <- c(single, fit0$time()$total)
  multi <- c(multi, fit1$time()$total)
  optim <- c(optim, fit2$time()$total)
  single_neff <- c(mean(fit0$summary(NULL,c("ess_bulk"))$ess_bulk), single_neff)
  multi_neff <- c(mean(fit1$summary(NULL,c("ess_bulk"))$ess_bulk), multi_neff)
  optim_neff <- c(mean(fit2$summary(NULL,c("ess_bulk"))$ess_bulk), optim_neff)
}
data.frame(single=single,
           multi=multi,
           optim=optim,
           single_neff=single_neff,
           multi_neff=multi_neff,
           optim_neff=optim_neff,
           seed=seeds) %>% write.csv(., file="mrp.csv")


