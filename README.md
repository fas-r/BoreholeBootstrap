# BoreholeBootstrap
"BoreholeBootstrap", an R script that performs borehole data bootstrap analysis for the paper titled "Evaluating the potential drilling success of exploration programs using three-dimensional geological models" by Z Harris et. al.

# Author
FAS Reyneke

# Synopsis
This R script imports and analyses borehole lode intersection data in CSV format. Two input files (one for "known" centre point boreholes and another for "test" boreholes) are provided as well as an output directory. A summarised CSV result file and graphs for each borehole bootstrap is provided as output.

# Instruction Guide
In order to run the script, do the following:
- Download and install the basic R environment on your machine (https://www.r-project.org/). R version 3.6.0 was used for the development of the script, but later versions should function out of the box.
- Using RGui or the command line, navigate to and open the "BoreholeBootstrap.R".
- Modify the DefaultOpenPath and DefaultSavePath path variables if you intend on doing a lot of file processing.
- Modify the "# Bootstrap settings" parameters to the desired values. BootstrapIterCount gives the number of bootstrap iterations to be performed. SamplesPerBootstrap identifys how many boreholes to be used as the sample for each bootstrap iteration. AreaSizeHectare defines the bounding (constraining) area around the known borehole. Sensible defaults have been chosen, with commented-out examples that match the outputs used in the manuscript as part of the script.
- Run the entire script. If this is the first time running the script for this machine and session, ggplot2 will be installed (and any underlying packages it may require). Installation will require access to the internet and is automatic. Subsequent runs of the script will be far faster.
- A pop-up dialog is displayed instructing to "Select Known Boreholes NoOfLodes file". This file indicates the "known" or centre borehole data point file. It is around these "known" boreholes that bootstrap testing will take place. Load the "TestData_KnownBoreholeNoOfLodes.csv" file.
- A second pop-up dialog is displayed instructing to "Select Test Boreholes NoOfLodes file". This file indicates the "test" or simulated borehole data point file. These are simulated points used for bootstrap testing. Load the "TestData_SimBoreholeNoOfLodes.csv" file.
- A final "Browse for folder" dialog is presented, asking the user to identify the output folder for the files that will be generated. Select a suitable directory on your machine. Note that previous data sets output to this folder will be silently overwritten if they have the same names.
- With the default test data and script settings, 6 files are generated:
- By varying the "# Bootstrap settings" parameters various data sets for the simulation can be obtained as given in the manuscript.

# Test Data
Execute the "BoreholeBootstrap.R" script using the "TestData_KnownBoreholeNoOfLodes.csv" and "TestData_SimBoreholeNoOfLodes.csv" files as input as per the Instruction Guide. These files are in the "Test Data" folder of the repository.

# Output Files
Executing the "BoreholeBootstrap.R" script on the provided Test Data, 6 files are generated. The files are provided in the "Output Files" folder of the repository as follows:
- BootstrapResults_10000_40.csv: A summary of mean and standard deviation statistics on all "known" borehole bootstrap results. Due to the randomised nature of bootstrap selection every run (even on the same machine) will be different to the next. For the provided test data and default settings the values obtained in this CSV file should be within 5% of the following values:

| Borehole ID | Mean | Std Dev |
| ------ | ------ | ------ |
| PB2 | 0.6015 | 0.05975 |
| PB38 | 0.4646 | 0.06109 |
| PB122 | 0.5716 | 0.06045 |
| PB192 | 0.8535 | 0.04383 |
| PB267 | 0.7858 | 0.05069 |

- PB2_10000_40.png: Bootstrap graph image result for "known" borehole PB2, at 10000 iterations of 40 samples over 1 ha. Displayed values should once again be within 5% of provided values.
- PB38_10000_40.png: Bootstrap graph image result for "known" borehole PB38, at 10000 iterations of 40 samples over 1 ha. Displayed values should once again be within 5% of provided values.
- PB122_10000_40.png: Bootstrap graph image result for "known" borehole PB122, at 10000 iterations of 40 samples over 1 ha. Displayed values should once again be within 5% of provided values.
- PB192_10000_40.png: Bootstrap graph image result for "known" borehole PB192, at 10000 iterations of 40 samples over 1 ha. Displayed values should once again be within 5% of provided values.
- PB267_10000_40.png: Bootstrap graph image result for "known" borehole PB267, at 10000 iterations of 40 samples over 1 ha. Displayed values should once again be within 5% of provided values.

# Compatibility notes and dependency information
This script was tested with R version 3.6.0 (https://www.r-project.org/)
It requires the "ggplot2" package to be installed (https://ggplot2.tidyverse.org/) which is intalled and added as a library in the beginning of the script.
