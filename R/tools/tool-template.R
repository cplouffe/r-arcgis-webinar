# R Tool Template ==============================================================

# Every R-ArcGIS tool that you create will follow the same general form.  You
# will need to define a function named 'tool_exec' within your R script.  This
# function will then be executed once you call the R script from within ArcGIS
# for Desktop (i.e., ArcMap, or ArcGIS Pro) via a GP tool.

# The tool_exec() function  has two arguments: in_params and out_params.  You
# can alias these arguments however you want, but we will be using the default
# names throughout this tutorial.

# Both in_params and out_params will be lists of parameters of provided from
# the user via the GP tool. Depending on how many parameters are provided,
# the lengths of these lists will differ.

tool_exec = function(in_params, out_params) {

  # You can assign input and output parameters to variables by specifying the
  # the appropriate element from the parameter lists.
  input_value = in_params[[1]]
  result = out_params[[1]]

  # Determine how many parameters are being passed:
  print(paste('Number of input parameters:', length(in_params), sep = ' '))
  print(paste('Number of output parameters:', length(out_params), sep = ' '))
  print(input_value)

  # You can use arc.progress_label() and arc.progress_pos() to indicate your
  # progress in your analysis.  These functions will give the user visual
  # feedback to help them understand which if any sections of the R-ArcGIS
  # GP tool are taking longer to complete, or are encountering errors.
  arc.progress_label('Setting progress...')
  arc.progress_pos(50)

  # Perform some analysis on your data...

  # Return results.
  return(out_params)

}
