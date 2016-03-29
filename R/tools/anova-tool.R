# R-ArcGIS ANOVA Tool ----------------------------------------------------------

# Execute R-ArcGIS ANOVA Tool
tool_exec = function(in_params, out_params) {

  # Load required packages
  arc.progress_label('Loading required R packages...')
  arc.progress_pos(25)
  pkgs = c('dplyr')
  load_pkgs(pkgs)

  # Print all inputs/outputs (uncomment for debugging)
  # print(in_params[[1]])
  # print(in_params[[2]])
  # print(in_params[[3]])
  # print(in_params[[4]])
  # print(out_params[[1]])
  # print(out_params[[2]])

  # Get parameters
  source_data = in_params[[1]]
  response_var = in_params[[2]]
  group_var = in_params[[3]]
  n_groups = as.integer(in_params[[4]])
  stats_table = out_params[[1]]
  anova_table = out_params[[2]]

  # Import data set to data frame
  arc.progress_label('Reading data...')
  arc.progress_pos(25)
  data = arc.open(source_data)
  data_df = arc.select(data, fields = c(response_var, group_var))

  # Group data into quantiles using group field
  grouped_df = data_df %>%
    mutate(group = ntile(.[[group_var]], n_groups)) %>%
    group_by(group)

  # Get summary stats from groups
  arc.progress_label('Calculating summary statistics for each group...')
  arc.progress_pos(50)

  summary_funcs = c('mean', 'sd')
  summary_df = grouped_df %>%
    summarize_each_(funs_(summary_funcs), response_var)

  # Write summary statistics to table
  if (!is.null(stats_table) && stats_table != 'NA') {
    arc.write(stats_table, summary_df)
  }

  # Create box and whisker plot
  boxplot(grouped_df[[response_var]] ~ grouped_df[['group']],
          ylab = response_var, xlab = 'Group')

  # Perform ANOVA
  arc.progress_label('Performing ANOVA...')
  arc.progress_pos(75)

  anova_fit = aov(grouped_df[[response_var]] ~ grouped_df[['group']])
  anova_results = summary(anova_fit)

  # Change name of grouping variable label in output, and write to data frame
  rownames(anova_results[[1]])[1] = group_var
  anova_df = as.data.frame(anova_results[[1]])

  # Write ANOVA results to table
  if (!is.null(anova_table) && anova_table != 'NA') {
    arc.write(anova_table, anova_df)
  }

  return(out_params)

}

# Install and load all packages provided from a character vector
load_pkgs = function(pkgs) {
  new_pkgs = pkgs[!(pkgs %in% installed.packages()[ , 'Package'])]
  if (length(new_pkgs) > 0) install.packages(new_pkgs)
  invisible(lapply(pkgs, function(x)
    suppressMessages(library(x, character.only = TRUE)))
  )
}

# Test tool in standalone R
# library(arcgisbinding)
# arc.check_product()
# source_data = 'data/r-arcgis-data.gdb/toronto_crime'
# response_var = 'Murders'
# group_var = 'Equity_Score'
# n_groups = 5
# stats_table = 'data/r-arcgis-data.gdb/summary_stats'
# anova_table = 'data/r-arcgis-data.gdb/anova_results'
