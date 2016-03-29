# R-ArcGIS Summarize Tool ------------------------------------------------------

# Execute R-ArcGIS Summarize Tool
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

  # Get parameters
  source_data = in_params[[1]]
  group_fields = unname(unlist(in_params[[2]]))
  summarize_field = in_params[[3]]
  summarize_func = in_params[[4]]
  final_df = out_params[[1]]

  # Import data set to data frame
  arc.progress_label('Reading data...')
  arc.progress_pos(50)
  data = arc.open(source_data)
  data_df = arc.select(data)

  # Create sorted data frame
  arc.progress_label('Summarizing selected columns by group fields...')
  arc.progress_pos(75)

  # Group the data frame using the selected group fields, and then summarize
  # the data frame by group using the provided functions.
  summarize_df = data.frame(data_df) %>%
    group_by_(.dots = group_fields) %>%
    summarize_each_(summarize_func, summarize_field)

  # Write data frame to output standalone table.
  arc.write(final_df, summarize_df)

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
# group_fields = unname(unlist(list(`NA` = 'Arsons', `NA` = 'Murders')))
# summarize_field = 'Total_Major_Crime_Incidents'
# summarize_func = 'mean'
# final_df = 'data/r-arcgis-data.gdb/summarize_crime'
