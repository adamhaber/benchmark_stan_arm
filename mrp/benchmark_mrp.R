library(cmdstanr)
library(rjson)

data = fromJSON(file = "mrp_all_ref.json")

mod0 <- cmdstan_model("mrp_ref.stan")
mod1 <- cmdstan_model("mrp_ref.stan", cpp_options = list(stan_threads = TRUE))
mod2 <- cmdstan_model("mrp_ref2.stan", cpp_options = list(stan_threads = TRUE, stan_cpp_optims = TRUE))

single <- c()
multi <- c()
optim <- c()
seeds <- c(1,2,3)
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
}
data.frame(single=single,
           multi=multi,
           optim=optim,
           seed=seeds) %>% write.csv(., file="mrp.csv")


