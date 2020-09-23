#!/usr/local/bin/Rscript
# USAGE: Rscript quick_cov.R <sample> <out_prefix>
# DESCRIPTION: Generates plots for quick_cov from telomere workflow

# Copyright (c) 2020, New York Genome Center
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the <organization> nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

################################################################################
##################### COPYRIGHT ################################################
# New York Genome Center
# Version: 0.3
# Author: Jennifer M Shelton, Andre Corvelo
##################### /COPYRIGHT ###############################################
################################################################################
################################################################################


###############################
#get arguments
###############################
args <- commandArgs(TRUE)
sample <- args[1]
prefix <- args[2]
plotting = FALSE
if (length(args) > 2){
    if (args[3] == '--plotting'){
        plotting = TRUE
    }
}
###############################
# Import libraries
###############################
library(lattice)
par(mar=c(8,4,4,2))

###############################
# Read from files
###############################
geno_cov <- read.delim(file('stdin') , sep="\t", header=FALSE)
colnames(geno_cov) <- c('chom', 'start', 'end', 'feat', 'score', 'strand')
###############################
# get coverage
###############################

geno_cov$cov <- geno_cov$score / (geno_cov$end - geno_cov$start)
dense <- density(geno_cov$cov)


cov <- dense$x[which.max(dense$y)]
cat(cov)
###############################
# Plot coverages
###############################
if (plotting){
    ###############################
    # Start PDF
    ###############################
    output_file <- paste(prefix, '_cov.pdf', sep='')
    pdf(output_file, bg='white')
    plot(dense,
    type='l',
    col='magenta',
    main=paste('Density plot of genomic coverage: ', sample, sep=''),
    xlab='Coverage',
    ylab='Probability density',
    xlim=c(0,200)
    )
    ###############################
    # Plot selected coverage
    ###############################
    abline(v=cov, lty = "dotted", col = "grey")
    text(x=cov,
    y=(max(dense$y)/2),
    labels=c(cov),
    cex = 0.50)
    
    plot_complete <- dev.off()
}
