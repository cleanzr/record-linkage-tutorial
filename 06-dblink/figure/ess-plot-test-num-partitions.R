library(dplyr)
library(mcmcse)
library(ggplot2)
library(stringr)
library(scales)

expt.dirs <- c("../../analyze/spark-eber-results/nltcs_6levels_med-prior_collapsed",
               "../../analyze/spark-eber-results/nltcs_5levels_med-prior_collapsed",
               "../../analyze/spark-eber-results/nltcs_4levels_med-prior_collapsed",
               "../../analyze/spark-eber-results/nltcs_3levels_med-prior_collapsed",
               "../../analyze/spark-eber-results/nltcs_2levels_med-prior_collapsed",
               "../../analyze/spark-eber-results/nltcs_1level_med-prior_collapsed",
               "../../analyze/spark-eber-results/nltcs_0levels_med-prior_collapsed")

save.fname <- "ess-plot-test-num-partitions"
plot.width <- 7
plot.height <- 2
range.iter <- c(0, 50000)
burnin.samples <- 50
num.points <- 200
exclude.k.clust.ess <- 9:12

theme_set(theme_bw() + theme(text = element_text(size = 9)))

results <- lapply(expt.dirs, function(dir) {
  # Read diagnostic CSV files from experiment
  diagnostics <- read.csv(paste(dir,"diagnostics.csv", sep="/"))
  clusters <- read.csv(paste(dir,"clusterSizeFreqDist.csv", sep="/"))
  names(clusters) <- c(names(clusters)[1], 
                       paste0(str_replace(names(clusters)[-1], pattern="X", replacement=""),"-clusters"))
  
  # Select iterations within specified range
  # (Reason: some experiments have been run for more iterations than others.)
  diagnostics <- diagnostics %>% 
    filter(iteration >= range.iter[1], iteration <= range.iter[2])
  clusters <- clusters %>% 
    filter(iteration >= range.iter[1], iteration <= range.iter[2])
  
  # Get number of partitions from the directory name of the experiment
  num.levels <- stringr::str_extract(dir, "\\d")
  num.partitions <- 2^as.integer(num.levels)
  
  # Calculate ESS at regular intervals (determined by `num.points` above)
  # and record the corresponding iteration + time in seconds.
  num.samples <- nrow(diagnostics)
  inc <- ceiling(num.samples / num.points)
  indices <- seq(from = burnin.samples, to = num.samples, by = inc)
  iteration <- diagnostics$iteration[indices]
  time <- diagnostics$systemTime.ms[indices]
  start.time <- diagnostics$systemTime.ms[1]
  time <- (time - start.time) * 10^-3
  
  # # ESS for number of observed entities
  ess.num.obs.ent <- sapply(indices, function(idx) {
    diagnostics$numObservedEntities[1:idx] %>% ess(method = "tukey") 
  })
  
  # ESS for aggregate distortions
  ess.agg.dist <- sapply(indices, function(idx) {
    diagnostics[1:idx,] %>% select(starts_with("aggDistortions")) %>% multiESS(method = "tukey")
  })
  
  # ESS for k-clusters
  ess.clust.size <- sapply(indices, function(idx) {
    clusters[1:idx,] %>% 
      select(-iteration, -one_of(paste0(exclude.k.clust.ess,"-clusters"))) %>% 
      multiESS(method = "tukey")
  })
  
  return(data.frame("iteration" = iteration, 
                    "time" = time, 
                    "num.partitions" = num.partitions,
                    "ess.variable" = rep(c("# observed entities", "attribute distortion", "cluster size distribution"), times = rep(length(indices), times = 3)),
                    "ess" = c(ess.num.obs.ent, ess.agg.dist, ess.clust.size)))
})

results.combined <- bind_rows(results)

mult_format <- function() {
  function(x) format(10^-4*x,digits = 2) 
}

pdf(paste0(save.fname, ".pdf"), height = plot.height, width = plot.width)
results.combined %>% 
  mutate(num.partitions = as.factor(num.partitions)) %>%
  ggplot(aes(x = time, y = ess, col = num.partitions)) + 
  geom_line(aes(linetype = num.partitions)) + 
  facet_wrap(~ess.variable, scales = "free_y") +
  scale_x_continuous(limits = c(0,50000), labels = function(x) format(1e-4*x,digits = 2)) + 
  scale_shape_manual(values = seq(0,7)) +
  labs(x = expression(Time~('×'*10^{4}~s)), y = "ESS", col = "# partitions", linetype = "# partitions") +
  theme(legend.margin=margin(0,0,0,0), legend.key.height = unit(10,"points"))
dev.off()

pdf(paste0(save.fname, "-speed-up.pdf"), height = 2.6, width = 3.35)
results.combined %>% 
  filter(ess > 100) %>%
  group_by(ess.variable, num.partitions) %>%
  arrange(num.partitions, iteration) %>%
  slice(1) %>%
  group_by(ess.variable) %>%
  mutate(speedup = sum(time*(num.partitions == 1))/time) %>%
  ggplot(aes(x = num.partitions, y = speedup, col = ess.variable)) + 
  geom_abline(slope = 1, intercept = 0) + 
  geom_point(aes(shape = ess.variable)) + 
  scale_y_continuous(limits = c(1, NA)) +
  guides(shape=guide_legend(ncol=1)) +
  labs(x = "# partitions", y = "Speed-up factor", col = "Summary stat.", shape = "Summary stat.") + 
  theme(legend.position="bottom", legend.margin=margin(0,0,0,0), legend.key.height = unit(10,"points"))
dev.off()
