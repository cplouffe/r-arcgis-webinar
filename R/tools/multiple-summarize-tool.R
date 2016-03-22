# R-ArcGIS Summarize Tool ------------------------------------------------------

# Execute R-ArcGIS Summarize Tool
tool_exec = function(in_params, out_params) {

  # Load required packages
  arc.progress_label('Loading required R packages...')
  arc.progress_pos(25)
  pkgs = c('dplyr')
  load_pkgs(pkgs)

  # Get parameters
  source_data = in_params[[1]]
  group_fields = unname(unlist(in_params[[2]]))
  summarize_fields = unname(unlist(in_params[[3]]))
  summarize_funcs = unname(unlist(in_params[[4]]))
  final_fc = out_params[[1]]

  # Import data set to data frame
  arc.progress_label('Reading data...')
  arc.progress_pos(50)
  data = arc.open(source_data)
  data_df = arc.select(data)

  # Create sorted data frame
  arc.progress_label('Summarizing selected columns by group fields...')
  arc.progress_pos(75)

  # Group the data frame using the selected group fields, and then summarize
  # the data frame by group using the provided functions.  Once analysis is
  # complete, join the results back to our original data frame.
  summarize_df = data.frame(data_df) %>%
    group_by_(.dots = group_fields) %>%
    summarize_each_(funs_(summarize_funcs), summarize_fields) %>%
    left_join(data_df)

  # Get names of new summary columns that were created
  new_cols = names(summarize_df)[!(names(summarize_df) %in% names(data_df))]

  # Add new columns to ArcGIS data frame
  # This is a somewhat hacky approach, as you can't use left_join() or cbind()
  # or it will cause the ArcGIS data frame to lose the arc.data class
  for (i in 1:length(new_cols)) {
    data_df[[new_cols[i]]] = summarize_df[[new_cols[i]]]
  }

  # Write data frame to output feature class.
  arc.write(final_fc, data_df)

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
