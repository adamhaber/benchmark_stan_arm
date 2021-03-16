library(cmdstanr)
library(brms)

set.seed(1234)
dat <- data.frame(
  y = rnbinom(1000, size = 10, mu = 5),
  x1 = rnorm(1000),
  x2 = rnorm(1000),
  g = factor(rep(1:100, each = 10))
)

seed = 1
fit0_brm <- brm(y ~ s(x1) + s(x2) + (1 | g), dat, family = negbinomial(),
           chains = 1, backend = "cmdstanr",
           seed = seed,
           control = list(adapt_delta = 0.95), iter = 1, warmup = 1)
fit1_brm <- brm(y ~ s(x1) + s(x2) + (1 | g), dat, family = negbinomial(), 
            chains = 1, backend = "cmdstanr",
            seed = seed,
            threads = threading(4, grainsize = 1),
            control = list(adapt_delta = 0.95), iter = 1, warmup = 1)

standata0 <- standata(fit0_brm)
standata1 <- standata(fit1_brm)

data0 <- list()
for (t in names(standata0)) {
  data0[[t]] <- standata0[[t]]
}
data1 <- list()
for (t in names(standata1)) {
  data1[[t]] <- standata1[[t]]
}

mod0 <- cmdstan_model(write_stan_file(stancode(fit0_brm)))
mod1 <- cmdstan_model(write_stan_file(stancode(fit1_brm)), cpp_options = list(stan_threads = TRUE))

single <- c()
multi <- c()
seeds <- c(1,2,3)
for (seed in seeds) {
  fit0 <- mod0$sample(data0,
                     seed = seed,
                     chains = 4,
                     parallel_chains = 4)
  
  fit1 <- mod1$sample(data1,
                      chains = 4,
                      seed = seed,
                      parallel_chains = 4,
                      threads_per_chain = 8)
  
  single <- c(single, fit0$time()$total)
  multi <- c(multi, fit1$time()$total)
}
data.frame(single=single,
           multi=multi,
           optim=optim,
           seed=seeds) %>% write.csv(., file="brms_model.csv")