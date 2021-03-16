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
seeds <- c(1,2,3)
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
}
data.frame(single=single,
           multi=multi,
           optim=optim,
           seed=seeds) %>% write.csv(., file="reduce_sum_tutorial.csv")
