library(cmdstanr)

d <- read.csv("RedcardData.csv", stringsAsFactors = FALSE)
d2 <- d[!is.na(d$rater1),]
redcard_data <- list(n_redcards = d2$redCards, n_games = d2$games, rating = d2$rater1)
redcard_data$N <- nrow(d2)
logistic0 <- cmdstan_model("logistic0.stan")
logistic1 <- cmdstan_model("logistic1.stan", cpp_options = list(stan_threads = TRUE))
logistic2 <- cmdstan_model("logistic2.stan", cpp_options = list(stan_threads = TRUE, stan_cpp_optims = TRUE))
redcard_data$grainsize <- 1

single <- c()
multi <- c()
optim <- c()
single_neff <- c()
multi_neff <- c()
optim_neff <- c()
seeds <- c(1,2,3,4,5)
for (seed in seeds) {
  fit0 <- logistic0$sample(redcard_data,
                           seed = seed,
                           chains = 4,
                           parallel_chains = 4)
  
  fit1 <- logistic1$sample(redcard_data,
                           chains = 4,
                           seed = seed,
                           parallel_chains = 4,
                           threads_per_chain = 8)
  
  fit2 <- logistic2$sample(redcard_data,
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
           seed=seeds) %>% write.csv(., file="reduce_sum_tutorial.csv")
