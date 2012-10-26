Feature: Fill out CA Clarity PPM Timesheets based on effort tracking from VersionOne.
	As an organization with Agile Teams and a PMO,
	We want to use time-tracking from VersionOne to update Clarity PPM Timesheets
	So that senior management can understand capacity without the burden of double entry.

	Background:
		Given an instance of Clarity PPM named "clarityppm"
		And an instance of VersionOne named "versionone"

	Scenario: Reconcile does not show unmatched projects
		Given a project called "Big Data" in "clarityppm"
		And a project called "Big Data" in "versionone"
		And there has not been active integration between the 2 systems
		When I run the Project Reconciliation Process
		Then I see "Big Data" in a list of VersionOne projects
		And the "Big Data" row has no associated Clarity PPM project.

	Scenario: Reconcile shows matched projects
		Given a project called "Call Center" in "clarityppm"
		And that project has an ID of "1000"
		And a project called "Call Center" in "versionone"
		And that project has a Reference value of "1000"
		When I run the Project Reconciliation Process
		Then I see "Call Center" in a list of VersionOne projects
		And the "Call Center" row has an associated Clarity PPM project name of "Call Center".

	Scenario: Reconcile does not show unmatched users
		Given a resource named "Niku Administrator" in "clarityppm"
		And that resource has an email address of "v1clarityppm@mailinator.com"
		And a member named "admin" in "versionone"
		And that member has a blank email address
		When I run the Member Reconciliation Process
		Then I see "admin" in a list of VersionOne Members
		And the "admin" row has no associated Clarity PPM resource.

	Scenario: Reconcile shows matched users
		Given a resource named "Danny Developer" in "clarityppm"
		And that resource has an email address of "andre@mailinator.com"
		And a member named "Danny Developer" in "versionone"
		And that member has an email address of "andre@mailinator.com"
		When I run the Member Reconciliation Process
		Then I see "Andre Agile" in a list of VersionOne Members
		And the "Andre Agile" row has an associated Clarity PPM resource name of "Andre Agile".

	Scenario: Reconcile ignores tasks with no ID
		Given a task named "Sample: Service Change" in "clarityppm"
		And that task has a blank task ID
		And a task named "Sample: Service Change" in "versionone"
		And that task has a blank Reference value
		When I run the Task Reconciliation Process
		Then I see "Sample: Service Change" in a list of VersionOne Tasks
		And the "Sample: Service Change" row has no associated Clarity PPM task.
		And "Sample: Service Change" does not appear in any row as a Clarity PPM task.

	Scenario: Reconcile does not show unmatched tasks
		Given a task named "Sample: Build UI" in "clarityppm"
		And that task has a task ID of "CCT-0001"
		And a task named "Sample: Build UI" in "versionone"
		And that task has a blank Reference value
		When I run the Task Reconciliation Process
		Then I see "Sample: Build UI" in a list of VersionOne Tasks
		And the "Sample: Build UI" row has no associated Clarity PPM task.

	Scenario: Reconcile shows matched tasks
		Given a task named "Sample: Code Review" in "Call Center" in "clarityppm"
		And that task has a task ID of "CCT-0002"
		And a task named "Sample: Code Review" in "versionone"
		And that task has a Reference value of "CCT-0002"
		When I run the Task Reconciliation Process
		Then I see "Sample: Code Review" in a list of VersionOne Tasks
		And the "Sample: Code Review" row has an associated Clarity PPM task name of "Sample: Code Review".

	Scenario: Integration does not update timesheets when there are no new actuals
		Given "versionone" has no Actuals since the last-sync date
		When I run the main integration process
		Then it finds nothing to synchronize
		And exits gracefully.

	Scenario: Integration enters time for a single new actual on an empty timesheet
		Given a task named "Sample: Create Performance Tests" in "Call Center" in "clarityppm"
		And that task has a task ID of "CCT-0003"
		And a task named "Sample: Create Performance Tests" in "Call Center" in "versionone"
		And that task has a Reference value of "CCT-0003"
		And an actual on that task with a value of "2"
		And that actual was the only one created after the last-sync date
		And that actual was logged for the date "Monday, 29 October 2012"
		And that actual was logged for the member "Danny Developer"
		When I run the main integration process
		Then it finds the time period for "29 October 2012 to 5 November 2012"
		And it finds the timesheet for "Danny Developer"
		And it adds a row for "Sample: Create Performance Tests"
		And it adds "2" in the column for "Monday, 29 October 2012"

	Scenario: Integration enters time for multiple actuals on different days

	Scenario: Integration accumulates time for multiple actuals on the same day
		Given a task named "Sample: Code Review" in "Call Center" in "clarityppm"
		And that task has a task ID of "CCT-0002"
		And a task named "Sample: Code Review" in "Call Center" in "versionone"
		And that task has a Reference value of "CCT-0002"
		And two actuals on that task created after the last-sync date
		And those actuals have <date>, <member>, and <value>
		When I run the main integration process
		Then it finds the time period for "29 October 2012 to 5 November 2012"
		And it finds the timesheet for "Danny Developer"
		And it adds a row for "Sample: Create Performance Tests"
		And it adds "6" in the column for "Monday, 29 October 2012"

		Examples:
			| date                    | member          | value |
			| Monday, October 30 2012 | Danny Developer | 4     |
			| Monday, October 30 2012 | Danny Developer | 2     |

	Scenario: Integration adds time to existing entries on a timesheet when there are new actuals
