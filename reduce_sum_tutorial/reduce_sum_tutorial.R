library(cmdstanr)

d <- read.csv("RedcardData.csv", stringsAsFactors = FALSE)
d2 <- d[!is.na(d$rater1),]

redcard_data <- list(n_redcards = d2$redCards, n_games = d2$games, rating = d2$rater1)
redcard_data$N <- nrow(d2)
redcard_data$grainsize <- 1

models <- list()
models[["single"]] <- cmdstan_model("logistic.stan")
models[["threads-no-flags"]] <- cmdstan_model("logistic_reduce_sum.stan", cpp_options = list(stan_threads = TRUE))
models[["threads-optims"]] <- cmdstan_model("logistic_reduce_sum.stan", exe_file = "threaded_optims", cpp_options = list(stan_threads = TRUE))
models[["threads-norangechecks"]] <- cmdstan_model("logistic_reduce_sum.stan", exe_file = "threaded_norangeheck", cpp_options = list(stan_threads = TRUE, stan_no_range_checks = TRUE))
models[["threads-norangechecks-optims"]] <- cmdstan_model("logistic_reduce_sum.stan", exe_file = "threaded_norangecheck_optims", cpp_options = list(stan_threads = TRUE, stan_cpp_optims = TRUE, stan_no_range_checks = TRUE))

seeds <- c(1)#,2,3,4,5)
repeats <- 1
chains = c(1,2)#,4)
threads <- c(2)#, 4, 8, 16)

iter_warmup <- 1000
iter_sampling <- 1000

results <- data.frame()

is_threaded_model <- function(model) {
  is.null(model$cpp_options()[["stan_threads"]]) || !isTRUE(model$cpp_options()[["stan_threads"]])
}

for (n in names(models)) {
  for (ch in chains) { 
    if (is_threaded_model(models[[n]])) {
    threads_vec <- 1
    } else {
    threads_vec <- threads
    }
    for(t in threads_vec) {
      for (seed in seeds) {
        for (rep in repeats) {
          fit <- models[[n]]$sample(redcard_data,
                seed = seed,
                chains = ch,
                parallel_chains = ch,
                threads_per_chain = if (!is_threaded_model(models[[n]])) t else NULL,
                iter_warmup = iter_warmup,
                iter_sampling = iter_sampling)
          print(n)
          results <- rbind(results, list(
                            name = n,
                            chains = ch,
                            threads = t,
                            seed = seed,
                            rep = rep,
                            time = fit$time()$total,
                            neff = mean(fit$summary(NULL, c("ess_bulk"))$ess_bulk)
          ))
          print(results)
        }
      }
    }
  }
}
      
saveRDS(results, "reduce_sum_tutorial.RDS")
