.replaceFilePatterns <- function(filePath, dots, repldots,i) {
  # this function replace all patterns in one input file for a given index i in 1..maxlength 
  tmpfile <- filePath  
  # for each input file, replace all matching parameters patterns             
  for (j in 1:length(dots)) { 
    nm = names(dots[j])
    if (is.null(nm) || nchar(nm) == 0) {
      pattern = str_c("%",j,"%")
    } else {
      pattern = str_c("%",nm,"%")
    }
    replval <- repldots[[j]][[i]] 
    # TODO issue warning if replval is not scalar
    if (grepl(pattern, tmpfile, fixed = TRUE)) {
      tmpfile <- gsub(pattern,replval, tmpfile,fixed=TRUE)      
    }
  }       
  return(tmpfile)
};


PASolve <- function(funname, ..., varies=NULL, input.files=list(), output.files=list(), client = .scheduler.client, in.dir = getwd(), out.dir = getwd(), .debug = PADebug()) {
  if (client == NULL || is.jnull(client) ) {
    stop("You are not currently connected to the scheduler, use PAConnect")
  }   
  
  fun <- match.fun(funname)
  dots <- list(...)
  repldots <- list()
  
  # compute maxlength (i.e. the length of the parameter which has the biggest length)
  maxlength = 0
  for (i in 1:length(dots)) {   
    if (is.null(varies) || is.element(i, varies) || (!is.null(names(dots[i])) && is.element(names(dots[i]),varies))) {      
      maxlength = max(maxlength, length(dots[[i]]))
    }
  }
  
  if (maxlength == 0) {
    error("No varying argument")
  }
  
  # harmonize parameters (i.e. extends each varying parameter to match the size of the biggest, by relooping)
  for (i in 1:length(dots)) {      
    if (is.null(varies) || is.element(i, varies) || (!is.null(names(dots[i])) && is.element(names(dots[i]),varies))) {
      len <- length(dots[[i]])
      nb_rep <- maxlength %/% len
      rem <- maxlength %% len
      if (rem != 0) {
         # TODO display a warning if the biggest length is not a multiple of this parameter's length
      } 
      if (is.null(names(dots[i])) || nchar(names(dots[i])) == 0)  {
        repldots[[i]] <- as.list(rep(dots[[i]],nb_rep,len = maxlength))
      } else {        
        tmplist <- as.list(rep(dots[[i]],nb_rep,len = maxlength))
        names(tmplist) <- rep(names(dots[i]),maxlength)
        repldots[[i]] <- tmplist                      
      }
      
    } else {
      # for unvarying parameter, replicate it as it is (i.e. a list is replicated into N lists,
      # instead of a list of size N)
      repldots[[i]] <- rep(dots[i],maxlength)       
    }
  }
  
  # now, for each original parameter, we have produced a list.
  # we want instead for each remote function call, the list of parameters associated
  # this is equivalent to a matrix transposition, but for lists :
  final.param.list <- list() 
  
  for (i in 1:maxlength) {
    tmp.param.list <- list()
    tmp.input.files <- list()
    tmp.output.files <- list()
    for (j in 1:length(dots)) {     
      tmp.param.list[j] = repldots[[j]][i]      
      nm = names(repldots[[j]][i])
      if (!is.null(nm) && !is.na(nm)) {
        names(tmp.param.list)[j] <- nm
      } else {
        names(tmp.param.list)[j] <- ""
      }
      
    }   
    final.param.list[[i]] = tmp.param.list
  }
  
  # pattern replacements in input files  
  final.input.files <- list()  
  if (length(input.files) > 0) {
    for (i in 1:maxlength) {
      tmp.input.files <- list();
      for (k in 1:length(input.files)) {
        tmp.input.files[[k]] <- .replaceFilePatterns(input.files[[k]], dots, repldots,i);               
      }   
      final.input.files[[i]] <- tmp.input.files 
    }      
  }
  
  # pattern replacements in output files  
  # pattern replacements in input files  
  final.output.files <- list()  
  if (length(output.files) > 0) {
    for (i in 1:maxlength) {
      tmp.output.files <- list();
      for (k in 1:length(output.files)) {
        tmp.output.files[[k]] <- .replaceFilePatterns(output.files[[k]], dots, repldots,i);               
      }   
      final.output.files[[i]] <- tmp.output.files 
    }      
  }
  
  final.calls <- list()
  for (i in 1:maxlength) {
    output <- str_c("result = ",funname,"(")
    for (j in 1:length(dots)) {   
      nname = names(final.param.list[[i]][j])
      if (is.null(nname) || nchar(nname) == 0) {
        output<- str_c(output,final.param.list[[i]][[j]],sep=" ")
      } else {
        output<- str_c(output,nname,"=")
        output<- str_c(output,final.param.list[[i]][[j]],sep=" ")
      }
      
      if (j < length(dots) ) {        
        output<- str_c(output,",")     
      }
    }
    output<- str_c(output,")",sep="")    
    final.calls[[i]] <- output
  }
    
  if (.debug) {
    print("PASolve execution of : ")
    # print the command produced for debug    
    for (i in 1:maxlength) {
      cat(funname,"(",sep="")
      for (j in 1:length(dots)) {   
        nname = names(final.param.list[[i]][j])
        if (is.null(nname) || nchar(nname) == 0) {
          cat(final.param.list[[i]][[j]],sep=" ")
        } else {
          cat(nname,"=",sep="")
          cat(final.param.list[[i]][[j]],sep=" ")
        }
        
        if (j < length(dots) ) {        
          cat(",")     
        }
      }
          
      cat(")",sep="")
      
      if (length(input.files) > 0) {
        cat(", in.f : { ")
        for (k in 1:length(input.files)) {
          cat(final.input.files[[i]][[k]],sep=" ")
          if (j < length(input.files) ) {        
            cat(",")     
          }
        }
        cat(" } ")
      } 
      if (length(output.files) > 0) {
        cat(", out.f : { ")
        for (k in 1:length(output.files)) {
          cat(final.output.files[[i]][[k]],sep=" ")
          if (j < length(output.files) ) {        
            cat(",")     
          }
        }
        cat(" } ")
      } 
      
      cat("\n",sep="")
    }  
  }
  
  
  tnames <- ""
  job <- PAJob()
  hash <- job@hash
  
  
  if (typeof(fun) == "closure") {
    # save function dependencies and push it to the space, only for closure
    env_file <- str_replace_all(file.path(tempdir(),hash,"PASolve.rdata"),fixed("\\"), "/")
    
    .PASolve_saveDependencies(funname, env_file, .do.verbose=.debug)
    pasolvefile <- PAFile("PASolve.rdata",hash = hash,working.dir = file.path(str_replace_all(tempdir(),fixed("\\"), "/"),hash))
    pushFile(pasolvefile, client = client)
  }
  
  for (i in 1:maxlength) {
    tnames[i] <- str_c("t",i)
    t <- PATask(tnames[i])  
    total_script <- str_c("setwd(file.path(getwd(),\"",hash,"\"))\n")
    if (.debug) {
      total_script <- str_c(total_script, "print(paste(\"Working directory is :\",getwd()))\n")
      total_script <- str_c(total_script, "print(\"Working directory content :\")\n")
      total_script <- str_c(total_script, "print(list.files(getwd()))\n")
    }
    total_script <- str_c(total_script, "load(\"PASolve.rdata\")\n")
    total_script <- str_c(total_script, final.calls[[i]])
    setScript(t,total_script)  
    
    if (length(input.files) > 0) {
      tmp.input.files <- final.input.files[[i]]
      for (j in 1:length(tmp.input.files)) {
        pafile <- PAFile(tmp.input.files[[j]], hash = hash, working.dir = in.dir)
        pushFile(pafile, client = client)
        addInputFiles(t) <- pafile      
      }
    }
    if (typeof(fun) == "closure") {
      # the function dependency is always added as an input file
      addInputFiles(t) <- pasolvefile   
    }
    
    if (length(output.files) > 0) {
      tmp.output.files <- final.output.files[[i]]
      for (j in 1:length(tmp.output.files)) {
        pafile <- PAFile(tmp.output.files[[j]], hash = hash, working.dir = out.dir)
        addOutputFiles(t) <- pafile
      }
    }
    
    addTask(job) <- t    
  }
  if (.debug) {
    print("Submitting job : ")
    cat(toString(job))
  }
  jobid <- j_try_catch(client$submit(getJavaObject(job)))
  cat(str_c("Job submitted (id : ",jobid$value(),")","\n"))
  jobresult <- PAJobResult(job, jobid$value(),  tnames, client)
  return(jobresult)
};