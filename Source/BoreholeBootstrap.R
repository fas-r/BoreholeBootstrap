#    R script that performs borehole data bootstrap analysis for the paper titled 
#    "Evaluating the potential drilling success of exploration programs using 
#    three-dimensional geological models" by Z Harris et. al.
#    Copyright (C) 2020  FAS Reyneke
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#    This software is hosted at https://github.com/fas-r/BoreholeBootstrap

# Packages
install.packages("ggplot2")
library("ggplot2")

# Settings
DefaultOpenPath <- "C:\\Path\\To\\Input\\Data\\."
DefaultSavePath <- "C:\\Path\\To\\Output"

# Single Bootstrap Functions
Bootstrap.Borehole <- function(BhName, PngOutFolder, TestBhData, CenterBhLodes, 
    NoOfIter, NoOfSamples, AreaHaSize, BinWidth = 0.025) {
    # Generate Answer Vector
    OutputValues <- c(1:NoOfIter)
    
    # Run Bootstrap
    for (bsi in 1:NoOfIter) {
        # Grab a new sample set
        BootstrapSample <- sample(TestBhData$NoOfLodes, NoOfSamples, 
            replace = FALSE)
        # BootstrapSample = sample.custom(TestBhData$NoOfLodes,
        # NoOfSamples) Force first sample to known (center point) value
        BootstrapSample[1] <- CenterBhLodes
        # Calculate P(>0) statistic and save for this sample
        OutputValues[bsi] <- length(which(BootstrapSample > 0))/NoOfSamples
    }
    
    # Calculate overall statistics
    OutputMean <- mean(OutputValues)
    OutputStdDev <- sd(OutputValues)
    
    # Generate plot data
    BinData <- findInterval(seq(0, 1, by = BinWidth), OutputValues[order(OutputValues)])
	# Note that we want probabilities from 0 to 1, but, ggplot2 has issues with plotting
	# geom_col on a continuous X axis. Therefore, scale up by 1000, and manually rename
	# the labels of the scale later to be from 0 to 1. This implies any X axis values
	# must be mutliplied by 1000 to plot correctly. The resulting figure is still correct.
    BinXvals <- seq(0, 1, by = BinWidth) * 1000
    BinYvals <- c(0, diff(BinData))
    BinYCumvals <- BinData[1:length(BinYvals)]
	
	# Define X labels (giving correct values from 0 to 1)
	XLabels = c("0.00", "0.05", "0.10", "0.15", "0.20", "0.25", "0.30",
		"0.35", "0.40", "0.45", "0.50", "0.55", "0.60", "0.65", "0.70", "0.75",
		"0.80", "0.85", "0.90", "0.95", "1.00")
    
    # Create PNG Graph Output
    OutFilePath <- paste0(PngOutFolder, BhName, "_", NoOfIter, "_", 
        NoOfSamples, ".png")
    
    # Plot Histogram / Mean / Cum Freq
    PlotTitleText <- paste0("Bootstrap result for ", BhName)
    PlotTitleSubText <- paste0("(", NoOfIter, " iterations of ", NoOfSamples, 
        " samples over ", AreaHaSize, " ha) ", "[Mean: ", signif(OutputMean, 
            6), "] [Std Dev: ", signif(OutputStdDev, 6), "]")
    p <- ggplot(data.frame(BinXvals, BinYvals), aes(BinXvals, BinYvals), 
        fill = BinXvals)
    p <- p + theme(axis.line = element_line(color = "black", size = 1, 
        linetype = "solid"), legend.position = "right", legend.justification = c(0, 
        1))
    p <- p + geom_col(aes(y = BinYvals, color = "Frequency", fill = "Frequency", 
        linetype = "Frequency", size = "Frequency"))
    p <- p + geom_vline(aes(xintercept = OutputMean * 1000.0, color = "Mean", 
        fill = "Mean", linetype = "Mean", size = "Mean"))
    p <- p + geom_line(aes(x = BinXvals, y = BinYCumvals/max(BinYCumvals) * 
        max(BinYvals), color = "Cumulative %", fill = "Cumulative %", 
        linetype = "Cumulative %", size = "Cumulative %"))
    p <- p + labs(colour = "Datasets", title = PlotTitleText, subtitle = PlotTitleSubText, 
        x = "P(Number of lodes > 0)", y = "Frequency [Counts]")
    p <- p + scale_x_continuous(breaks = (seq(0, 1, 0.05) * 1000), limits = c(0.0, 
        1000.0), labels=XLabels)
    p <- p + scale_y_continuous(sec.axis = sec_axis(~. * (1/max(BinYvals)), 
        name = "Cumulative Frequency [%]"))
    p <- p + scale_color_manual(name = "Legend", breaks = c("Frequency", 
        "Mean", "Cumulative %"), values = c(Frequency = "black", Mean = "black", 
        `Cumulative %` = "#F49842"))
    p <- p + scale_fill_manual(name = "Legend", breaks = c("Frequency", 
        "Mean", "Cumulative %"), values = c(Frequency = "#4171F4", 
        Mean = "white", `Cumulative %` = "white"))
    p <- p + scale_linetype_manual(name = "Legend", breaks = c("Frequency", 
        "Mean", "Cumulative %"), values = c(Frequency = "blank", Mean = "twodash", 
        `Cumulative %` = "solid"))
    p <- p + scale_size_manual(name = "Legend", breaks = c("Frequency", 
        "Mean", "Cumulative %"), values = c(Frequency = 0, Mean = 1.5, 
        `Cumulative %` = 1.5))
    p
    
    # Save plot to file, notifying user
    print(paste0("Saving graph to ", OutFilePath, " ..."), quote = FALSE)
    ggsave(p, file = OutFilePath, units = "cm", dpi = 300, width = 25, 
        height = 14)
    
    # Delete the plot object
    rm(p)
    
    # Return Value
    c(OutputMean, OutputStdDev)
}

# Gather NoOfLodes per Known Borehole

# Select File
InputFilePath <- choose.files(default = DefaultOpenPath, 
	caption = "Select Known Boreholes NoOfLodes file", multi = FALSE)
# Read the file to a DataFrame
dfKnownBoreholes <- read.csv(InputFilePath)
# Show input data
str(dfKnownBoreholes)

# Gather NoOfLodes per Test Borehole

# Select File
InputFilePath <- choose.files(default = DefaultOpenPath,
    caption = "Select Test Boreholes NoOfLodes file", multi = FALSE)
# Read the file to a DataFrame
dfTestBoreholes <- read.csv(InputFilePath)
# Show input data
str(dfTestBoreholes)

# Get Output Folder
OutFolderPath <- choose.dir(default = DefaultSavePath,
	caption = "Select output folder (for PNG image files)")
OutFolderPath <- paste0(OutFolderPath, "\\")

# Multiple Bootstrap Function
Bootstrap.multiple <- function(CentreBoreholes, TestBoreholes, SampleCount, 
    BootCount, AreaSizeHa) {
    
    KnownBoreholeCount <- length(CentreBoreholes$NoOfLodes)
    
    # Generate Result Data Frame
    BootstrapResults <- data.frame(Hole.id = CentreBoreholes$Hole.id, 
        Mean = c(1:KnownBoreholeCount), StdDev = c(1:KnownBoreholeCount))
    
    # Iterate through Known Boreholes
    for (kbi in 1:KnownBoreholeCount) {
        # Print user feedback
        print(paste0("Analysing borehole ", CentreBoreholes$Hole.id[kbi], 
            " input data..."), quote = FALSE)
        
        # Print Indexes found for this known borehole
        dfTestBoreholeData <- TestBoreholes[grep(paste0(CentreBoreholes$Hole.id[kbi], 
            "_"), TestBoreholes$Hole.id), ]
        print(paste0(length(dfTestBoreholeData$NoOfLodes), " test boreholes found for ", 
            CentreBoreholes$Hole.id[kbi], "."), quote = FALSE)
        
        # Perform Bootstrap
        RetVal <- Bootstrap.Borehole(CentreBoreholes$Hole.id[kbi], 
            OutFolderPath, dfTestBoreholeData, CentreBoreholes$NoOfLodes[kbi], 
            BootCount, SampleCount, AreaSizeHa)
        
        # Save Result
        BootstrapResults$Hole.id[kbi] <- CentreBoreholes$Hole.id[kbi]
        BootstrapResults$Mean[kbi] <- RetVal[1]
        BootstrapResults$StdDev[kbi] <- RetVal[2]
        
        # Output result to CSV
        write.csv(BootstrapResults, paste0(OutFolderPath, paste0("BootstrapResults", 
            "_", BootCount, "_", SampleCount, ".csv")))
        
        print(paste0("Bootstrap result for ", CentreBoreholes$Hole.id[kbi], 
            " complete (", BootCount, " iterations; Mean: ", signif(RetVal[1], 
                6), "; StdDev: ", signif(RetVal[2], 6), ")."), quote = FALSE)
    }
}

# Bootstrap settings
BootstrapIterCount <- 10000
SamplesPerBootstrap <- 40
AreaSizeHectare <- 1

# Execute
Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, SamplesPerBootstrap, 
    BootstrapIterCount, AreaSizeHectare)

# 1ha_1000_it_20_40_sample
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 20, 1000, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 40, 1000, 1)

# 10ha_1000_it_20_40_sample
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 20, 1000, 10)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 40, 1000, 10)

# 100ha_1000_it_20_40_sample
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 20, 1000, 100)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 40, 1000, 100)

# 50_test_1ha_1000_it_20_40_sample
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 20, 1000, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 40, 1000, 1)

# multi_it_1ha_20_40_sample
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 20, 10, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 20, 50, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 20, 100, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 20, 200, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 20, 500, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 20, 1000, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 20, 2000, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 20, 5000, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 20, 7000, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 40, 10, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 40, 50, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 40, 100, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 40, 200, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 40, 500, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 40, 1000, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 40, 2000, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 40, 5000, 1)
#    Bootstrap.multiple(dfKnownBoreholes, dfTestBoreholes, 40, 7000, 1)

