#Gain Index code#

This repository hosts all the files and code to generate the Gain Index
2012, available at [index.gain.org](index.gain.org).

Note: The repository with the [code for the Index website is
here](https://github.com/globalai/Index-site).



##Some remarks##

* *Gain.xls* Contains all the out of the code. This file is the Excel
  version of the Index.

* *Main.xls* is the file that hosts the VBA macros, all parameters and
  instructions.

* *Gain-GDP.xls* makes, via live formulas, the GDP adjusted scores. the
  values are added back into *Gain.xls* via live formulas.

* *Exportcsv folder* is the output of the VBA macro to prepare the Index data to
  be ingested by the website. **Please note** that there are some extra
steps to comply with format requirments. See Issue #50.

* *Measure importer* is hosts the VBA code that autmatically formats the
  updated data from WBA or WorldBank sources. Input files are located in
*Raw0 folder*.

* *Legacy folder* has the corresponding files from last year. Also
  available via Git history.

* *Macros folder* has the 2 non-standard libraries to calculate
  correlation and regresions properly (built-in functions cannot handle
missing data properly).

##Running the Pipeline##

Open the *Main.xls* file. Clear the column "exclude" and click DoAll. It
will take around 3 hours to complete. Not sure by so much.

File Gain-dev.LOG logs the progress.

**Since Excel uses the clipboard for moving data, you should not copy
anything while the code runs, or you might overwrite data.**


##To Do##

I would like to port this code into a more semsible language that
supports >2D data. Probably python, or even JS.


##Concept of the pipeline

1. Missing Raw scores are filled up if possible via linear
   interpolation, and constant extrapolation.
2. Values are normalized using saturation level and linear
   normalization.
3. Values are aggregated into the partial Scores, and total Scores.
   Tolerance for missing values is considered in this step.
4. All *meta output* such us quick rankings, calculation of Matrix
   limits, GDP adjusted scores, etc are calculated instantly from
the output *Gain.xls* via live Formulas.
