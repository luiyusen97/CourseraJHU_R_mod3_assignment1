Introduction
============

This is a codebook describing the variables, data and transformations
performed on the raw data. For details on raw data, refer to readme and
features\_info text files in the rawdata folder.

Variables for dat\_avg\_values.txt
==================================

This data contains the mean calculated from each mean and standard
deviation variable in the raw data. it is ordered by subject, then
activity type. The following table describes the first 4 ordering and
descriptor variables in the dataframe. The other measurement variables
are described together with the dataframe containing the original
measurements, which have been re-ordered.

<table>
<caption>Identifier variables and their descriptions.</caption>
<thead>
<tr class="header">
<th style="text-align: left;">Variables</th>
<th style="text-align: left;">Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">ele.activity</td>
<td style="text-align: left;">Variable used for grouping purposes.</td>
</tr>
<tr class="even">
<td style="text-align: left;">subject</td>
<td style="text-align: left;">Identifier variable for subjects. Each number represents a unique subject, ranging from 1 to 30. Numeric variable.</td>
</tr>
<tr class="odd">
<td style="text-align: left;">activity</td>
<td style="text-align: left;">Identifier factor variable for the various activities in the experiment. Each number represents a type of activity performed by each subject, ranging from 1 to 6. Factor levels and their corresponding character string descriptors are: 1: WALKING 2: WALKING_UPSTAIRS 3: WALKING_DOWNSTAIRS 4: SITTING 5: STANDING 6: LAYING</td>
</tr>
<tr class="even">
<td style="text-align: left;">experimenttype</td>
<td style="text-align: left;">Identifier factor variable for experiment type, ranging from 1 to 2. Factor levels and their corresponding character string descriptors are: 1: train 2: test 70% of subjects were in the train experiment, and the other 30% were in the test experiment.</td>
</tr>
</tbody>
</table>

The rest of the variables to the right are calculated mean values. The
average was taken of the original raw data variables, grouped by
activity.

Variables for dat\_merge\_ordered.txt
=====================================

This dataset contains the re-ordered rawdata without any calculations
done to the values. Data is ordered by subject, then activity.
Individual subjects’ datasets (with all 6 activities per subject) are in
the output//individualsubjectdata// folder. The first 3 variables are
the same as in dat\_avg\_values.txt, and are identifier variables. The
rest are the same as in the raw data. The data taken only contains the
mean and standard deviations of the measured data. Detailed descriptions
for those can be found in the raw data folder, with the filepath of UCI
HAR Dataset//features\_info.txt.

Changes made to data to produce the 2 datasets
==============================================

1.  I read the rawdata sets for x\_train.txt and x\_text.txt.
    features.txt contains the column names for each dataset.
    train//y\_train.txt contains the activity factor variable for train,
    train//subject\_train.txt contains the subject identifier variable
    for the train set.
2.  test//y\_test.txt and test//subject\_test contained the respective
    identifier variables for the test dataset. activity\_labels.txt
    contained the descriptor character strings for the activity factor
    variable. I attached this to the levels attribute of the activity
    factor variable. The experiment type factor variable was created by
    myself, then attached to the factor variable’s levels.
3.  I column bound the subject and activity variables to the left of
    both dataframes, then row bound the test dataframe to the bottom of
    the train dataframe.
4.  I selected all mean (mean()) and standard deviation (std())
    variables and discarded the rest.
5.  I split the merged dataframe (dat\_merge) by the subject identifier
    variable, resulting in 30 dataframes. Then, I ordered each dataframe
    by the activity factor variable. These dataframes are stored in the
    output//individualsubjectdata// folder, named and numbered
    accordingly.
6.  The individual dataframes were then row bound to form a larger
    dataframe stored in dat\_merge\_ordered.txt, ordered by subject,
    then activity.
7.  I iterated through each individual subject’s dataframe and
    calculated the mean for each measurement column using summarise.
8.  Since summarise creates a new dataframe, I row bound the dataframes
    to a larger dataframe stored in dat\_avg\_values.txt. These are also
    ordered by subject, then activity.
9.  Thus, the output is 2 dataframes, one containing the order raw data,
    the other containing the means calculated from the raw data for each
    activity, orderd by subject.

Instructions for reading the 2 dataframes from output// folder
==============================================================

The column names can be read by simply setting the header parameter to
TRUE in read.table. The values are tab separated. The activity factor
levels can be read from activity\_levels.txt, while the experiment type
factor levels can be read from experimenttype\_levels.txt. Please ignore
the ele$activity column, it is only there for grouping and ordering
purposes.
