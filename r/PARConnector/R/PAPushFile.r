PAPushFile <- function(space, path, fileName, inputFile, 
                       client = PAClient(), .print.stack = TRUE) {
  
  if (client == NULL || is.jnull(client) ) {
    stop("You are not currently connected to the scheduler, use PAConnect")
  } 
  pushed <- FALSE
  
  j_try_catch(
    pushed <- J(client, "pushFile", .getSpaceName(space), path, fileName, inputFile),     
    .handler = function(e,.print.stack) {
      if (.print.stack) {
        print(str_c("Error in PAPushFile(",space,",",path,",",fileName,",",inputFile,") : ", e$jobj$getMessage()))
      }
    PAHandler(e,.print.stack)
  },.print.stack = .print.stack)
  return (pushed)
}