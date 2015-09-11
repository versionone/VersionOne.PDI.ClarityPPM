# VersionOne Integration for Clarity PPM

VersionOne Integration for Clarity PPM is a set of maps and processes for the
[Pervasive Data Integrator](http://integration.pervasive.com/Products/Pervasive-Data-Integrator.aspx)
that can be used as building blocks for integrating VersionOne and Clarity
PPM. Although these maps and processes require the commercial Pervasive Data
Integrator product, the maps and processes themselves are free, licensed under
a modified BSD license, which reflects our intent that anyone can use the maps and processes without any obligations.

![Workflows for VersionOne Integration for Clarity PPM](workflow.png)

## Demand Management

*Reconcile Projects* - When you configure the integration for the first time, you will want to reconcile the projects manually. The process `p_reconcile_projects` creates a spreadsheet showing VersionOne projects mapped to Clarity PPM projects. Depending on the usage patterns across the tools, the reconciliation spreadsheet may have many uses:

* If you are configuring the products for the first time, it may indicate a project you need to update with a reference.
* If you are diagnosing a problem with timesheets, time logged in that project won't be connected to Clarity PPM.
* If you are auditing the agile project portfolio, it may indicate planning that senior management hasn't approved.

*Create New VersionOne Projects* - Once you have created links between projects that already exist, the process `ClarityPPM_Projects_to_VersionOne` creates new VersionOne projects from Clarity PPM projects, where there is no reference. This reduces the manual effort required to keep VersionOne up-to-date when new projects start. Most importantly, automation ensures the Clarity PPM ID matches so processes described below can map to the appropriate project.

## Status Reporting

*Project Summary* - The process `VersionOne_Project_to_ClarityPPM` aggregates both completed and total story points from VersionOne projects, calculates percent complete, and populates the associated Clarity PPM projects with that data.

## Resource Management

*Reconcile Resources* - There are no user synchronization processes in this integration; therefore, users in each system are mapped by the convention that VersionOne email address matches the Clarity PPM ID. Since both fields can be hand-edited, there is the possibility of error. Again, reconciling is helpful to correct errors and to troubleshoot the integration. The process `p_reconcile_resources` creates a spreadsheet showing VersionOne members mapped to Clarity PPM resources.

*Reconcile Tasks* - Tasks can be mapped by hand, if necessary. Otherwise, reconciliation at this low level should be just for troubleshooting. The process `p_reconcile_tasks` creates a spreadsheet showing VersionOne workitems mapped to Clarity PPM tasks.

*Fill Out Timesheets* - The process begins by reading from a local file the date of the most recent actual that has been integrated. If the date is not read correctly the process logs an error message and exit. Once the date is read, the subprocess `p_GetDateRange_VersionOne` uses it to query VersionOne to find the minimum and maximum dates of the actuals that will be integrated, and stores these dates in macros. If there are no new actuals found then the process terminates.  Once the dates are found, the process reads the new actuals from VersionOne and stores them in memory, then reads the existing TimePeriods from Clarity PPM that cover the date range that were found in the previous step. Then it iterates through the Clarity PPM actuals and adds all incoming values to the appropriate day. If it does not insert any new actuals, the process logs a message and exits. Finally the updated TimePeriods are sent to Clarity PPM.

## Configuration

### Macros

PDI uses macros for configuration of the workflows and mappings. The following should be configured in PDI as a Macro Set:
`DATA` - A directory on the PDI server where the integration places intermediate and output files. It is recommended that this directory be configured as a network share so the reconciliation files can be accessed easily.
`Clarity_endpoint` - The HTTP URL for the Clarity PPM XOG web service. The default would look something like `http://clarityppm.example.com/niku/xog`.
`Clarity_username` - The username for PDI to use as credentials for connecting to Clarity PPM.
`Clarity_password` - The password for the integration to use as credentials for Clarity PPM.
`VersionOne_endpoint` - The HTTP URL for the VersionOne REST-API web service. The default would look something like `https://www1.v1host.com/v1clarityppm/rest-1.v1/data/`.
`VersionOne_username` - The username for PDI to use as credentials for connecting to VersionOne.
`VersionOne_password` - The password for PDI to use as credentials for connecting to VersionOne.

### Datetime File

The integration requires a tcd ext file on the server that contains the change date of the most recently integrated VersionOne actual. This date gets updated every time that new actuals are integrated, but when creating the file before the first execution the date should be in a format that VersionOne understands as part of a where clause in a URL query string, for example `YYYY-MM-DDThh:mm:ss.SSS`. For the first execution it is recommended that you set the date to any arbitrary date in the past that is guaranteed to be before the day that users began logging actuals in VersionOne. It is important to note that the day that the time was logged for is irrelevant, as the integration picks up any actuals that were added or modified since the date that is saved in the text file.

### Workflow and Mapping Configurations

When working with the workflows and mappings in the PDI Designer, it may be necessary to override development-time configurations. For each process and map, you may need to do the following:

1. Open the configurations.
2. Select the default configuration.
3. On the Macro Set tab, add the Macro Set to the project.
4. On the Macro tab, make sure all the "Include or Override" options are unchecked (meaning the values are included from the Macro Set).
5. Save Configuration.

### Fixing Schemas

PDI has a schemas for each Clarity PPM and VersionOne. Customization in either product may require refreshing the schemas so PDI can present an accurate set of fields to be mapped. For each process and map, you may need to:

1. Open the Map.
2. Select the Source data set.
3. Select the menu option for Change Schema.
4. Click the Change Schema button.
5. Open the data source.
6. Click Start Session.
7. Click Establish Connection.
8. Save the data source and close its tab.
9. Back in the change source schema dialog, refresh the schema from the data source.
10. Save the schema.
11. Launch designer for the source dataset.
12. Start Session.
13. Establish Connection.
14. Save the dataset.
25. Save Configuration.

### Fix XSLT

From time to time, PDI "forgets" the XSLT script that normalizes the VersionOne XML. You may need to:

1. Select the XSLT step.
2. Re-select the XSLT script.
3. Open the script.
4. Click OK.
5. Save the Process.

## Troubleshooting

In some cases the integration may not behave as you expect. You may want to begin by inspecting the detailed scenarios for the maps and processes.

* [Reconcile](https://github.com/versionone/VersionOne.PDI.ClarityPPM/blob/master/reconcile.feature) - scenarios for all 3 of the spreadsheet generation processes.
* [Timesheet](https://github.com/versionone/VersionOne.PDI.ClarityPPM/blob/master/timesheet.feature) - scenarios for the timesheet process.

The next step in troubleshooting is to look at the process execution log. Many of the steps in the process print useful information and error messages to the log, which can be helpful in tracking down exactly where things went wrong. If you are able to narrow it down to one of the steps that is causing the problem, the next step is to look at the files (on the server) that are generated by the integration. Here is a list of the process steps that produce files:

* In the `Create V1 lookup table` sub-process, two files are created: `VersionOne_resources_fixed.xml` and `VersionOne_reconcile_resources.csv`. The XML file shows all of the Members that were read from VersionOne, and the CSV file shows which VersionOne emails (if any) were matched with an email in Clarity PPM. If the `Clarity ID` and `Clarity Name` columns are empty then no emails were matched and the integration is unable to insert any actuals.
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

## Known Issues

* Does not write back Clarity PPM Task IDs to VersionOne.
* When timesheet do not exist, the actuals are not written back.
