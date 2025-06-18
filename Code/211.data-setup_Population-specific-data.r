rm(list=ls())

args <- commandArgs(TRUE)
DATATAG <- args[1] # "ChineseData_Global_TotalGM"
IndexTag <- args[2] # TotalGM
dataPath <- args[3]
FFlag <- args[4]

DATA.TAG <- DATATAG
Datadir <- paste0(dataPath, "/", DATA.TAG, ".csv")

if (FFlag == "Global" || FFlag == "Sub") {
  ZZScore <- 10000
} else if (FFlag == "DK34_GrayVol" || FFlag == "DK34_SurfArea") {
  ZZScore <- 100
} else if (FFlag == "DK34_ThickAvg") {
  ZZScore <- 1
} else {
  ZZScore <- 1
}

if (IndexTag == "TotalThickAvg" || IndexTag == "TotalCurvInd" || IndexTag == "TotalFoldInd") {
  ZZScore <- 1
}



## COMMON LIBRARIES AND FUNCTIONS
source("100.common-variables.r")
source("101.common-functions.r")

source("200.variables.r")

## SCRIPT SPECIFIC LIBRARIES

## SCRIPT SPECIFIC FUNCTIONS

## SCRIPT CODE
##
##
for( TESTING in c(1) ) {
  Print.Disclaimer( )
  
  ##
  ## Load and clean real data
  ## (note, most cleaning done by RB in other prior to running this script)
  ##
  
  RAW.DATA <- read.csv(Datadir,stringsAsFactors = TRUE)
  RAW.DATA <- RAW.DATA[ RAW.DATA$RunID=="FirstRun", ]
  

  RAW.DATA$Sex <- ifelse(RAW.DATA$Sex == 0, "Female",
                     ifelse(RAW.DATA$Sex == 1, "Male", RAW.DATA$Sex))
  

  
  ##
  ## Perform any transformations necessary for fitting
  ## 
  ## NOTE: for fp()/bfp() functions, Cov$X must be POSITIVE (apply a shift) and SMALL (apply a scaling factor)
  ##
  TRANSFORMATIONS <- list()
  TRANSFORMATIONS[[ "X" ]] <- list("OriginalName"="Age",
                                   "TransformedName"="AgeTransformed",
                                   "toTransformed"=function(Z) { log(Z) }, ## must manually scale X-variable for numerical stability within bfpNA()
                                   "toOriginal"=function(Z) { exp(Z) }
  )
  RAW.DATA[,TRANSFORMATIONS[["X"]][["TransformedName"]]] <- TRANSFORMATIONS[["X"]][["toTransformed"]]( RAW.DATA[, TRANSFORMATIONS[["X"]][["OriginalName"]] ] )
  
  TRANSFORMATIONS[[ "Y" ]] <- list("OriginalName"="OUTCOME", ## We will update these in a moment
                                   "TransformedName"="OUTCOMETransformed",
                                   "toTransformed"=function(Z) { Z / ZZScore }, ## must manually scale X-variable for numerical stability within bfpNA()
                                   "toOriginal"=function(Z) { Z * ZZScore }
  )
  
  for( OUTCOME in c(IndexTag) ) {
    RAW.DATA[,sprintf("%sTransformed",OUTCOME)] <- TRANSFORMATIONS[["Y"]][["toTransformed"]]( RAW.DATA[, OUTCOME ] )
  }
  
  ##
  ## Clean columns and factors
  ## NOTE: Use Additional-element to retain columns not used in the modelling (model columns are Outcomes+Covariates)
  ##
  n <- nrow(RAW.DATA)
  # RAW.DATA$Type <- sample(c("CN", "notCN"), size = n, replace = TRUE, prob = c(1/3, 2/3))
  RAW.DATA$Type <- sample(c("CN"), size = n, replace = TRUE)
  RAW.DATA$dx <-RAW.DATA$Type
  
  COLUMNS <- list(Outcomes=c( paste0(IndexTag, "Transformed") ),
                  Covariates=c("AgeTransformed","Study","EulerNumber","Sex","dx"),
                  Additional=c("SubID","SiteID","Age","RunID","Group")
  )
  # if( 1 ) {
  #   Sufficiently.Complete.Columns <- names( which( sapply( RAW.DATA, function(X){ sum(!is.na(X))/length(X) } ) > 0.75 ) )
  #   cat("The following columns are 75% complete within RAW.DATA, but not saved within DATA or SUBSET - check:\n")
  #   print(Sufficiently.Complete.Columns[ !Sufficiently.Complete.Columns %in% unique(c(unlist(COLUMNS),sub("Transformed","",COLUMNS$Outcomes))) ])
  #   
  #   cat("We note a columns called 'age', which is almost equal to 'age_days', but contains NAs. For those NAs what is the mean of 'age_days'?\n")
  #   AGG <- aggregate( age_days ~ study, data=droplevels(RAW.DATA[is.na(RAW.DATA$age),]),FUN=function(X){c(mean=mean(X),n=length(X))}, simplify=TRUE )
  #   AGG$age_years <- AGG$age_days[,"mean"]/365.25
  #   print(AGG)
  #   cat("Are we happy with the above list of studies with missing age (but available age_days)?\n")
  # }
  
  
  DATA <- RAW.DATA[,unlist(COLUMNS)] ## only keep selected columns
  rm(RAW.DATA)
  # DATA$Sex <- ifelse(DATA$Sex == 0, "female",
  #                    ifelse(DATA$Sex == 1, "male", DATA$Sex))
  DATA$sex.original <- DATA$Sex
  DATA$Sex <- factor( as.character(DATA$sex.original), levels=c("Female","Male") )
  warning("Assumptions regarding sex coding")

  is.factor(DATA$dx)
  DATA$dx <- as.factor(DATA$dx)
  DATA$dx <- relevel(DATA$dx,"CN")
  
  
  
  ##
  ## Manually drop specific unused levels
  ##
  DATA <- droplevels(DATA) # make sure there are no left over levels
  
  
  ##
  ## Add INDEX.TYPE column, a script-defined column to separate individuals used to fit the model (ie healthy controls)
  ##
  DATA$INDEX.TYPE   <- factor(DATA$dx=="CN",levels=c(TRUE,FALSE),labels=c("CN","notCN"))
  
  ##
  ## Create unique identifier (INDEX.ID) for each person across all studies
  ## NOTE: This column will be used in later scripts, so it must exist!
  ##
  DATA$INDEX.ID <- factor( paste( DATA$SiteID, DATA$SubID, DATA$Sex, sep="|" ) )
  warning("Created a bespoke INDEX.ID which \"should\" uniquely identify each individual")
  
  
  ##
  ## Check on missing data
  if( 1 ) {
    cat("Proportion of complete values by DATA columns:\n")
    sapply( DATA, function(X){ sum(!is.na(X))/length(X) } )
  }
  
  ##
  ## Reorder dataset
  ## NOTE: This assumes first scan (by age) corresponds to first scan of interest. This may not be true!
  ##
  DATA <- DATA[order(DATA$INDEX.ID,DATA$AgeTransformed),]
  # r <- c(rep(1, 15), rep(5, 5))
  r <- c(rep(1, 15))
  n <- nrow(DATA)
  
  DATA$run <- rep(r, length.out = n)
  DATA$INDICATOR.OB <- (DATA$run==1)
  COLUMNS$Additional <- append( COLUMNS$Additional, "INDICATOR.OB" )
  warning("Within real datasets using ( run==1 ) to select first run within each session")
  
  ##
  ## Create identifer for 'first' scan (INDEX.OB) within each person
  ## NOTE: This column will be used to subset to cross-sectional data, so it must exist!
  ##
  DATA$INDEX.OB <- NA
  DATA$INDEX.OB[ which(DATA$INDICATOR.OB) ] <- Reduce(c,lapply(rle(as.numeric(DATA$INDEX.ID[which(DATA$INDICATOR.OB)]))$lengths,function(k){1:k}))
  warning("Created a bespoke INDEX.OB which \"should\" identify repeat observations of individuals (akin to \"run\" variable)")
  
  
  
  ##
  ## Need to add these new columns to the 'to keep' list
  ##
  COLUMNS$Index <- c("INDEX.ID","INDEX.OB","INDEX.TYPE")
  
  
  
  ##
  ## Adding Outcome specific exclusion criteria
  ##
  # DATA[,"sGMVTransformed.DROP"] <- ifelse(DATA$fs_version=="FSInfant", TRUE, FALSE )
  # 
  # if( 0 ) {
  #   FTAB <- ftable(xtabs( ~ study + INDEX.TYPE, data=DATA[with(DATA,(INDEX.OB==1)&(!is.na(WMVTransformed))),] ))
  #   ORDER <- order(FTAB[,1])
  #   structure(.Data=FTAB[ORDER,],dim=dim(FTAB),class="ftable",row.vars=list(study=attr(FTAB,"row.vars")$study[ORDER]),col.vars=list(INDEX.TYPE=attr(FTAB,"col.vars")$INDEX.TYPE))
  # }
  # 
  # 
  # COLUMNS$Drop <- c("sGMVTransformed.DROP")
  
  
  
  ##
  ## Attaching some attributes
  ##
  attr(DATA,"columns") <- COLUMNS    
  
  attr(DATA,"tag") <- DATA.TAG
  
  attr(DATA,"Transformations") <- TRANSFORMATIONS
  
  
  ##
  ## Sanity checking dataset 
  ##
  # if( 1 ) {
  #   print( xtabs( ~ addNA(session) + addNA(INDEX.OB), data=DATA ) )
  #   warning("Must ensure session+run Vs INDEX.OB mis-matches are valid (see commented out code to investigate mis-matches)")
  #   
  #   cat("\n\n")
  # }
  # 
  
  ##
  ## Save dataset in RDS format for use in later scripts
  ##
  DATA.PATH <- file.path( RDS.DIR, DATA.TAG )
  if( !dir.exists( DATA.PATH ) ) {
    dir.create( DATA.PATH )
  }
  
  TOSAVE <- DATA[ , unlist(COLUMNS) ]
  
  attributes(TOSAVE) <- c( attributes(TOSAVE), attributes(DATA)[c("columns","tag","Transformations")] )
  
  Check.Attributes(TOSAVE)
  
  saveRDS(object=TOSAVE,
          file=file.path( DATA.PATH, "DATA.rds"))
  
  
  
  ##
  ## ==============================
  ## Below this point we generate SUBSETs, MODELs, NOVEL datasets derived from DATA
  ##
  
  
  
  for( OUTCOME in COLUMNS$Outcomes) {
    
    
    PATHS.LIST <- Create.Folders( Tag=sprintf("%s-%s", DATA.TAG, OUTCOME ) )
    
    ##
    ## Generate subsets (by outcome[=column] and included/excluded[=rows])
    ## NOTE: excluded implicitly means cross-sectional, ie. only 'first' observation
    ##
    
    WHICH <- list()
    
    WHICH$BASELINE.CONTROL <- with(DATA, (INDEX.TYPE==levels(INDEX.TYPE)[1]) & (INDEX.OB==1))
    warning("Current SUBSET is based on INDEX.ID and INDEX.OB assumptions, these might not be the correct way to subset the data")
    
    ## Following is outcome-specific code
    if(!is.null(COLUMNS$Drop)){
      MATCH <- match(x=sprintf("%s.DROP",OUTCOME), table=COLUMNS$Drop )
      if( !is.na(MATCH) ) {
        WHICH$KEEP <- !DATA[,COLUMNS$Drop] ## above we specify in terms of which rows to drop, so we must negate to keep those we want to KEEP
        cat("Outcome specific subsetting:",OUTCOME," (dropping ",sum(!WHICH$KEEP,na.rm=TRUE)," rows)\n")
      } else {
        WHICH$KEEP <- rep(TRUE,NROW(DATA))
      }
    } else {
      WHICH$KEEP <- rep(TRUE,NROW(DATA))
    }
    
    
    
    ##
    ## Check for NAs in Outcome, Covariates, Index and Drop columns (not Additional, since they do not impact fitting by definition)
    #WHICH$VALID <- Reduce(`&`, lapply( DATA[c(OUTCOME,unlist( attr(DATA,"columns")[c("Covariates", "Index", "Drop")] ) )], function(X){!is.na(X)} ) )
    WHICH$VALID <- Reduce(`&`, lapply( DATA[c(OUTCOME,unlist( attr(DATA,"columns")[c("Covariates", "Index")] ) )], function(X){!is.na(X)} ) )
    
    #WHICH.COLUMNS <- c( OUTCOME, unlist( attr(DATA,"columns")[c("Covariates", "Additional", "Index", "Drop")] ) ) ## note explicitly including OUTCOME
    WHICH.COLUMNS <- c( OUTCOME, unlist( attr(DATA,"columns")[c("Covariates", "Additional", "Index")] ) ) ## note explicitly including OUTCOME
    
    
    
    SUBSET <- droplevels( DATA[ Reduce( `&`, WHICH ), WHICH.COLUMNS ] )
    
    cat( "Subset", PATHS.LIST$PATH, "has", NROW(SUBSET), "rows.\n")
    
    attributes(SUBSET) <- c( attributes(SUBSET), attributes(DATA)[c("columns", "tag","Transformations")] )
    
    attr(SUBSET,"DATA.WHICH.LIST") <- WHICH
    
    ## Set the per-SUBSET trasnformation names for the Y-variable
    ## NOTE: we could imagine doing the outcome transformations within this for-loop
    ##       but since it is common to all outcomes, might as well do it above
    ##       (hence the need for thse lines below to 'fix' the Y-variable name)
    attr(SUBSET,"Transformations")[["Y"]]$OriginalName <- sub("Transformed","",OUTCOME)
    attr(SUBSET,"Transformations")[["Y"]]$TransformedName <- OUTCOME
    
    saveRDS(object=SUBSET, file=file.path(PATHS.LIST$PATH,"SUBSET.rds"))
    
    
    ##
    ## Generate model sets
    ##
    cat("Generating models...\n")
    
    
    ## NOTE: FAMILY.SET allows us to explore multiple gamlss outcome distributions, later scripts will select the 'best' (via AIC/BIC/etc)
    FAMILY.SET <- c("GGalt")
    FP.SET <- matrix(c(1,1,0,
                       2,1,0,
                       2,2,0,
                       3,1,0,
                       3,2,0,
                       3,3,0),
                     byrow=TRUE,ncol=3,dimnames=list(NULL,c("mu","sigma","nu")))
    
    RANDOM.SET <- matrix(c(1,0,0,
                           1,1,0
    ),
    byrow=TRUE,ncol=3,dimnames=list(NULL,c("mu","sigma","nu")))
    row.names(RANDOM.SET) <- LETTERS[1:NROW(RANDOM.SET)]
    RANDOM.STR <- c(""," + random(Study)")
    
    for( lFAM in FAMILY.SET ) { ## loop to search multiple outcome distributions
      
      for( iFP in 1:NROW(FP.SET) ) {
        
        for( iRAND in 1:NROW(RANDOM.SET) ) {
          
          MODEL.NAME <- paste0("baseFO",paste0(FP.SET[iFP,],collapse=""),"R",paste0(RANDOM.SET[iRAND,],collapse=""))
          
          MODEL <- list(covariates=list("Y"=OUTCOME, ## The Outcome
                                        "X"="AgeTransformed", ## The main X-variable (continuous) for plotting against Y
                                        "ID"="SubID", ## Subject-level ID, will be superceded by INDEX.ID in later scripts
                                        "BY"="Sex", ## factor columns to stratify plots (and implicitly within the model)
                                        "COND"="dx", ## should be all equal to base case in fitted SUBSET
                                        "RANEF"="Study"),
                        family=lFAM,
                        #contrasts=list("Sex"="contr.sum"),
                        # contrasts=list("EulerNumber"="contr.sum"), ## (*1*) Make intercept interpretation as mean fs_version
                        stratify=c("Study","Sex"),
                        mu   =if(FP.SET[iFP,"mu"]>0){
                          sprintf("%s ~ 1 + Sex  + fp(AgeTransformed,npoly = %i)%s",
                                  OUTCOME,
                                  FP.SET[iFP,"mu"],
                                  RANDOM.STR[RANDOM.SET[iRAND,"mu"]+1])
                        } else {
                          sprintf("%s ~ 1 + Sex%s",
                                  OUTCOME,
                                  RANDOM.STR[RANDOM.SET[iRAND,"mu"]+1])
                        },
                        sigma=if(FP.SET[iFP,"sigma"]>0){
                          sprintf("%s ~ 1 + Sex + fp(AgeTransformed,npoly = %i)%s",
                                  OUTCOME,
                                  FP.SET[iFP,"sigma"],
                                  RANDOM.STR[RANDOM.SET[iRAND,"sigma"]+1])
                        } else {
                          sprintf("%s ~ 1 + Sex%s",
                                  OUTCOME,
                                  RANDOM.STR[RANDOM.SET[iRAND,"sigma"]+1])
                        },
                        nu   =if(FP.SET[iFP,"nu"]>0){
                          sprintf("%s ~ 1 + fp(AgeTransformed,npoly = %i)%s",
                                  OUTCOME,
                                  FP.SET[iFP,"nu"],
                                  RANDOM.STR[RANDOM.SET[iRAND,"nu"]+1])
                        } else {
                          sprintf("%s ~ 1%s",
                                  OUTCOME,
                                  RANDOM.STR[RANDOM.SET[iRAND,"nu"]+1])
                        },
                        inc.fp=TRUE)
          
          saveRDS(object=MODEL,file=file.path(PATHS.LIST$MODEL,sprintf("%s.%s.fp.rds",MODEL.NAME,lFAM)))
        }
      }
    }
  }
}

print( warnings() ) ## print any warnings from the code

