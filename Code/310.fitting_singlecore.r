rm(list=ls())


args <- commandArgs(TRUE)
DATATAG <- args[1] # "Chinese_AgeT_Global"
Indexflag <- args[2] # TotalGM
Id <- as.integer(args[3]) # Choose which model

## COMMON LIBRARIES AND FUNCTIONS
source("100.common-variables.r")
source("101.common-functions.r")


source("300.variables.r")
source("301.functions.r")

## SCRIPT SPECIFIC FUNCTIONS
if( 1 ) {


    if( exists("GAMLSS.CTRL") ) {
        cat("WARNING: GAMLSS.CTRL is already defined, within 310-fitting script we are over-writing it to maximise the chance of convergence.\n")
    }
    GAMLSS.CTRL <- gamlss.control(n.cyc=400)
    ## long tail for some iterations, since we only need to do this
    ## once (and use INIT within the bootstrapping) it is justified to
    ## have a large maximum iteration limit.
    ##
    ## Within the bootstraps we use the 'best' fit to seed, so expect
    ## to converge quicker
    ## Also, within the bootstrap we have a lower iteration limit
    ## because we expect some bootstrap replicates to be unstable
    ## (ie. not converge/fit)
}
## SCRIPT CODE
##
##
if( 1 ) { ## this block fits all models (and associated bfp-versions)
    Print.Disclaimer( )

    ##
    ## make fitting list
    TO.FIT <- list()
    COUNTER <- 1
    for( lset in FITTING.SET ) {
        PATHS.LIST <- Create.Folders( lset )
        MODEL.SET <- Find.Models.To.Fit( PATHS.LIST )
        for( lmod in MODEL.SET ) {
            TO.FIT[[COUNTER]] <- list(subset=lset,model=lmod)
            STR <- sprintf("[%3i] %s %s",COUNTER,lset,lmod)
            cat( STR, "\n" )
            COUNTER <- COUNTER + 1
        }
    }
    
    ## single job
    if (Id > 0 && Id <= length(TO.FIT)) {
        cat("Fitting model", Id, "of", length(TO.FIT), "\n")
        Fit.Function(idx=Id, List=TO.FIT)
    } else {
        stop(paste("Invalid Id:", Id, ". Must be between 1 and", length(TO.FIT)))
    }

}

print( warnings() ) ## print any warnings from the code
