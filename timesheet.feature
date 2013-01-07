Feature: Fill out CA Clarity PPM Timesheets based on effort tracking from VersionOne.
	As an organization with Agile Teams and a PMO,
	We want to use time-tracking from VersionOne to update Clarity PPM Timesheets
	So that senior management can understand capacity without the burden of double entry.

	Background:
		Given an instance of Clarity PPM named "clarityppm"
		And "clarityppm" has open time periods for:
			| name   | start           | end              |
			| Week 1 | 2 January 2012  | 8 January 2012   |
			| Week 2 | 9 January 2012  | 15 January 2012  |
			| Week 3 | 16 January 2012 | 22 January 2012  |
			| Week 4 | 23 January 2012 | 29 January 2012  |
			| Week 5 | 30 January 2012 | 5 February 2012  |
			| Week 6 | 6 February 2012 | 12 February 2012 |
		(<name> is not a Clarity PPM field but is used herein to reference these time periods.)

		And "clarityppm" has a resource named "Danny Developer" with an email address of "danny@mailinator.com"
		And "clarityppm" has a project named "Call Center" with an ID "1000"
		And "Call Center Release 1.0" has a task named "Quick Status Check Coding" with ID "CC1T-0001"

		Given an instance of VersionOne named "versionone"
		And "versionone" has a member named "Danny Developer" with an email address of "danny@mailinator.com"
		And "versionone" has a project named "Sample: Release 1.0" with a Reference value of "1000"
		And "versionone" has a schedule named "Sample: Call Center Schedule"
		And "Sample: Call Center Schedule" has a timebox named "Sample: Month C 1st Half"
		And "Sample: Month C 1st Half" has a start date of "2 January 2012"
		And "Sample: Month C 1st Half" has an end date of "12 February 2012"
		And "Sample: Release 1.0" is assigned to "Sample: Call Center Schedule"
		And "Sample: Release 1.0" has a story named "Sample: Quick Status Check"
		And "Sample: Quick Status Check" is assigned to "Sample: Month C 1st Half"
		And "Sample: Quick Status Check" has a task named "Code" with a Reference value of "CC1T-0001"


	Scenario: Integration does not update timesheets when there are no new actuals.
		Given "versionone" has no Actuals since the last-sync date
		When I run the main integration process
		Then it finds nothing to synchronize
		And exits gracefully.

	Scenario: Integration enters time for a single new actual on an empty timesheet.
		Given "Danny Developer" has no time sheet entries for "Week 1" 
		And "Code" has an actual created after the last-sync date:
			| date                       | member          | value |
			| Monday, 2 January 2012     | Danny Developer | 1     |
		When I run the main integration process
		Then "Danny Developer" has a time sheet entry for "Week 1":
			| task                      | date                       | value |
			| Quick Status Check Coding | Monday, 2 January 2012     | 1     |

	Scenario: Integration adds time to an existing entry on a timesheet.
		Given "Danny Developer" has a time sheet for "Week 2" with an existing time sheet entry:
			| task                      | date                       | value |
			| Quick Status Check Coding | Monday, 9 January 2012     | 1     |
		And "Code" has an actual created after the last-sync date:
			| date                       | member          | value |
			| Monday, 9 January 2012     | Danny Developer | 7     |
		When I run the main integration process
		Then "Danny Developer" has a time sheet entry for the time period "Week 2":
			| task                      | date                       | value |
			| Quick Status Check Coding | Monday, 9 January 2012     | 8     |

	Scenario: Integration enters time for multiple actuals on different days.
		Given "Danny Developer" has no time sheet entries for "Week 3"
		And "Code" has two actuals created after the last-sync date:
			| date                       | member          | value |
			| Tuesday, 17 January 2012   | Danny Developer | 6     |
			| Wednesday, 18 January 2012 | Danny Developer | 5     |
		When I run the main integration process
		Then "Danny Developer" has time sheet entries for "Week 3":
			| task                      | date                       | value |
			| Quick Status Check Coding | Tuesday, 17 January 2012   | 6     |
			| Quick Status Check Coding | Wednesday, 18 January 2012 | 5     |

	Scenario: Integration accumulates time for multiple actuals on the same day.
		Given "Danny Developer" has no time sheet entries for "Week 4"
		And "Code" has two actuals created after the last-sync date:
			| date                       | member          | value |
			| Thursday, 26 January 2012  | Danny Developer | 4     |
			| Thursday, 26 January 2012  | Danny Developer | 2     |
		When I run the main integration process
		Then "Danny Developer" has a time sheet entry for "Week 4":
			| task                      | date                       | value |
			| Quick Status Check Coding | Tuesday, 26 January 2012   | 6     |

	Scenario: Integration skips actuals that do not refer to Clarity PPM.
		Given "Danny Developer" has no time sheet entries for "Week 5"
		And "clarityppm" has no task with ID "CC1T-0002"
		And "Sample: Quick Status Check" has a task named "Test" with a Reference value of "CC1T-0002"
		And "Test" has an actual created after the last-sync date:
			| date                       | member          | value |
			| Monday, 30 January 2012    | Danny Developer | 1     |
		When I run the main integration process
		Then "Danny Developer" has no time sheet entries for "Week 5"
		And I read a log message telling the actual was not processed.

	Scenario: Integration skips actuals that are not in a Timebox.
		Given "Danny Developer" has no time sheet entries for "Week 5"
		And "Sample: Release 1.0" has a story named "Sample: Delete RMA"
		And "Sample: Delete RMA" has a task named "Document" with a Reference value of "CC1T-0001"
		And "Sample: Delete RMA" is not in any Timebox (Sprint)
		And "Document" has an actual created after the last-sync date:
			| date                       | member          | value |
			| Tuesday, 31 January 2012   | Danny Developer | 1     |
		When I run the main integration process
		Then "Danny Developer" has no time sheet entries for "Week 5"

	Scenario: Integration creates missing tasks in Clarity PPM.
		Given "Danny Developer" has no time sheet entries for "Week 6"
		And "Sample: Release 1.0" has a story named "Sample: Enter RMA"
		And "Sample: Enter RMA" is assigned to "Sample: Month C 1st Half"
		And "Sample: Enter RMA" has a task named "Design" with no Reference value
		And "Design" has a Number of "Task.Number"
		And "Design" has an actual created after the last-sync date:
			| date                       | member          | value |
			| Monday, 6 February 2012    | Danny Developer | 1     |
		When I run the main integration process
		Then "Call Center Release 1.0" has a new task named "Design"
		And the new task has an ID of "Task.Number"
		And "Design" has a Reference value of "Task.Number"
		And "Danny Developer" has a time sheet entry for "Week 6":
			| task   | date                      | value |
			| Design | Monday, 6 February 2012   | 1     |



