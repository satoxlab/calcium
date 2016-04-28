get_args <- function(args) {

  if ( isTRUE(any(args == "--args")) ) {
    arg_start  <- which(args == "--args") + 1
    arg_end    <- length(args)
    args <- args[arg_start:arg_end]
    return(args)
  } else {
    cat("Not found.\n")
    q()
  }
}

args <- get_args(commandArgs())

adjust.directory.name <- function(x){
	if (length(grep("/$", x, perl=TRUE)) != 1){
		paste(x, "/", sep="")
	}
	x
}


RGECOdir         <- adjust.directory.name(args[1])
GFPdir           <- adjust.directory.name(args[2])
outputDir        <- adjust.directory.name(args[3])
estimateFileName <- args[4]

dir.create(outputDir)

RGECOfiles <- dir(RGECOdir)
GFPfiles   <- dir(GFPdir)

normalize.R.GECO <- function(i){
	RGECOdata   <- read.delim(paste(RGECOdir, RGECOfiles[i], sep=""), header=FALSE)
	GFPdata     <- read.delim(paste(GFPdir, GFPfiles[i], sep=""),   header=FALSE)
	RGECOvector <- log2(as.vector(as.matrix(RGECOdata)))
	GFPvector   <- log2(as.vector(as.matrix(GFPdata)))
    fm          <- lm(RGECOvector ~ GFPvector)
    
    normalizedVector <- RGECOvector - (fm$coefficients[1] + fm$coefficients[2]*GFPvector)
    normalizedMatrix <- matrix(2^normalizedVector, nrow=512, ncol=512)
    
    fileName  <- sub("w0001", "w000n", RGECOfiles[i])
    
    write.table(normalizedMatrix, file=paste(outputDir, fileName, sep=""), sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
    
    ## use the lines commented out for visualizing the fitted line.
    #fileName <- sub(".txt", ".png", fileName)
    #png(filename=paste(outputDir, fileName, sep=""))
    #plot(GFPvector, RGECOvector)
    #abline(fm, col="red")
    #dev.off()
    
    c(fm$coefficients[1], fm$coefficients[2])    
}

coefficientList <- apply(as.array(1:length(RGECOfiles)), 1, function(x) normalize.R.GECO(x))
write.table(coefficientList, file=paste("./", estimateFileName, sep=""), sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
