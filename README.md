# V1ClarityPPM

In many organizations, there is a tension between agile teams and their 
program management office (PMO). The agile teams struggle to report their work 
to the PMO, while the PMO struggles with monitoring agile projects. Both want 
tools that suit their particular needs but it is rare to find a combination 
that satisfies both interests. VersionOne's integration with Clarity PPM, 
built on the Pervasive Data Integrator, helps to ease this tension. The PMO 
can continue to manage the project in-take process using Clarity PPM's Demand 
Management features, while populating VersionOne's project structure when 
agile projects are ready to start. The PMO can maintain the bird's eye view of 
projects as a portfolio with automated project summary reporting from 
VersionOne that does not burden project managers with duplicate entry. The PMO 
can continue to leverage Clarity PPM's Resource Management features by 
populating time sheets from time-tracking in VersionOne. While these 
out-of-the-box integration capabilities help reduce the tension, Pervasive 
Data Integrator makes the integration easy to maintain and extend with visual 
designers for data mapping and automated workflows. That way, the integration 
can grow and evolve as both Agile and PPM processes evolve.

V1ClarityPPM is a set of maps and processes for the 
[Pervasive Data Integrator](http://integration.pervasive.com/Products/Pervasive-Data-Integrator.aspx) 
that can be used as building blocks for integrating VersionOne and Clarity 
PPM. Although these maps and processes require the commercial Pervasive Data 
Integrator product, the maps and processes themselves are free, licensed under 
a modified BSD license, which reflects our intent that anyone can use the maps and processes without any obligations.

## Demand Management
*Reconcile Projects* - When you configure the integration for the first time, you will want to reconcile the projects manually. The process `p_reconcile_projects` will create a spreadsheet showing VersionOne projects mapped to Clarity PPM projects. Depending on the usage patterns across the tools, the reconciliation spreadsheet may have many uses:
* If you are configuring the products for the first time, it may indicate a project you need to update with a reference.
* If you are diagnosing a problem with timesheets, time logged in that project won't be connected to Clarity PPM.
* If you are auditing the agile project portfolio, it may indicate planning that senior management hasn't approved.

*Create New VersionOne Projects*

## Status Reporting

*Project Summary*

## Resource Management
*Reconcile Resources* - There are no user synchronization processes in this integration; therefore, users in each system are mapped by the convention that VersionOne email address matches the Clarity PPM ID. But both fields can be hand-edited so there is the possibility of error. Again, reconciling is helpful to correct errors and to troubleshoot the integration. The process `p_reconcile_resources` will create a spreadsheet showing VersionOne members mapped to Clarity PPM resources.

*Reconcile Tasks* - Tasks can be mapped by hand, if necessary. Otherwise, reconciliation at this low level should be just for troubleshooting. The process `p_reconcile_tasks` will create a spreadsheet showing VersionOne workitems mapped to Clarity PPM tasks.

*Fill Out Timesheets* - The process begins by reading from a local file the date of the most recent actual that has been integrated. If the date is not read correctly the process will log an error message and exit. Once the date is read, the subprocess `p_GetDateRange_VersionOne` uses it to query VersionOne to find the minimum and maximum dates of the actuals that will be integrated, and stores these dates in macros. If there are no new actuals found then the process terminates.  Once the dates are found, the process reads the new actuals from VersionOne and stores them in memory, then reads the existing TimePeriods from Clarity PPM that cover the date range that were found in the previous step. Then it iterates through the Clarity PPM actuals and adds all incoming values to the appropriate day. If it does not insert any new actuals, the process logs a message and exits. Finally the updated TimePeriods are sent to Clarity PPM.

## Configuration

The integration requires that there exists a text file on the server that contains the change date of the most recently integrated VersionOne actual.  This date will get updated every time that new actuals are integrated, but when creating the file before the first execution the date should be in a format that VersionOne will understand as part of a where clause in a URL query string, for example `YYYY-MM-DDThh:mm:ss.SSS`. For the first execution it is recommended that you set the date to any arbitrary date in the past that is guaranteed to be before the day that users began logging actuals in VersionOne. It is important to note that the day that the time was logged for is irrelevant, as the integration will pick up any actuals that were added or modified since the date that is saved in the text file.

## Troubleshooting

In some cases the integration may not behave as you expect. You may want to begin by inspecting the detailed scenarios for the maps and processes.
* [Reconcile](https://github.com/versionone/V1ClarityPPM/blob/master/reconcile.feature) - scenarios for all 3 of the spreadsheet generation processes.
* [Timesheet](https://github.com/versionone/V1ClarityPPM/blob/master/timesheet.feature) - scenarios for the timesheet process.

The next step in troubleshooting is to look at the process execution log. Many of the steps in the process print useful information and error messages to the log, which can be helpful in tracking down exactly where things went wrong. If you are able to narrow it down to one of the steps that is causing the problem, the next step is to look at the files (on the server) that are generated by the integration. Here is a list of the process steps that will produce files:
* In the `Create V1 lookup table` sub-process, two files are created: `VersionOne_resources_fixed.xml` and `VersionOne_reconcile_resources.csv`. The XML file shows all of the Members that were read from VersionOne, and the CSV file shows which VersionOne emails (if any) were matched with an email in Clarity PPM. If the `Clarity ID` and `Clarity Name` columns are empty then no emails were matched and the integration will be unable to insert any actuals.
* In the `Read V1 Actuals` sub-process, one file is created: `VersionOne_Actuals.xml`. This file contains all of the actuals that were read from VersionOne.
* In the `Read Clarity TimePeriods` map, one file is created: `ClarityTimePeriodRead.xml`. This file contains all of the Clarity PPM TimePeriods that cover the range of the actuals that were read from VersionOne.
* In the `Insert new Actuals` map, one file is created: `Data_sent_to_Clarity.xml`. This file contains the Clarity PPM `TimePeriods` that have been updated with the new `Actuals` from VersionOne. This file allows you to see exactly what the data looks like when it gets sent to Clarity. By looking at the main process log and comparing this XML file to the `ClarityTimePeriodRead.xml` file, you can determine what incoming actuals were inserted where.
* In the `Write to Clarity` map, one file is created: `Clarity_batch_response.txt`. This file contains the response that is returned from the Clarity PPM API when the data is sent. A FATAL error in the batch response indicates that there is an issue with the data, and the error description should point to the cause of the problem.

## Required Fields for Writing TimePeriods to Clarity

The following is a list of fields that must be present in order to write TimePeriods to Clarity PPM:

* TimePeriod: finish, start
* TimeSheet: ID, resourceID, version, status
* TimeSheetEntry: internalTaskID AND projectID, OR chargeCodeID, OR assignmentID
* Actual: actualDate, amount
