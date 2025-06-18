rm(list=ls())

args <- commandArgs(TRUE)
DATATAG <- args[1] # "Chinese_AgeT_Global"
Indexflag <- args[2] # TotalGM
Id <- as.integer(args[3])


## COMMON LIBRARIES AND FUNCTIONS
source("100.common-variables.r")
source("101.common-functions.r")

source("300.variables.r")
source("301.functions.r")


if( 1 ) {
    Print.Disclaimer( )

    ##
    ## Local variables
    ##
    
    for( lset in BOOT.SET ) {
        cat( "=====", lset, "=====\n" )

        PATHS.LIST <- Create.Folders( Tag=lset )
        
        HOLDER <- Load.Subset.Wrapper( Tag=lset, LSubset=TRUE, LModel=TRUE, LFit=TRUE )
        
        ## 执行单个 BOOT
        BOOT.EXTRACT <- list() 
        n <- Id
        cat("Running bootstrap replicate", n, "of", BOOT.OPT$Number.Replicates, "\n")
        BOOT.EXTRACT[[1]] <- Boot.Function(n=n, Base.Seed=BOOT.OPT$Seed, Holder=HOLDER)
        
        saveRDS(object=BOOT.EXTRACT,file=file.path(PATHS.LIST$BOOT.EXTRACT,sprintf("s%05i+th%05i.rds",BOOT.OPT$Seed,n)))

    }


    
}


print( warnings() ) ## print any warnings from the code
