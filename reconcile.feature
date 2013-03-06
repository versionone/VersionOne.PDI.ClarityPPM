Feature: Reconcile Clarity PPM and VersionOne objects.
	As an organization with Agile Teams using VersionOne and a PMO using Clarity PPM,
	We want to match up projects, people, and tasks
	So that integration workflows that depend on cross-product references will be able to operate correctly.

	Background:
		Given an instance of Clarity PPM named "clarityppm"
		And "clarityppm" has a resource named "Andre Agile" with an email address of "andre@mailinator.com"
		And "clarityppm" has a project named "Call Center Release 2.0" with an ID "2000"
		And "Call Center Release 2.0" has a task named "Field Completion Coding" with ID "CC2T-0001"

		Given an instance of VersionOne named "versionone"
		And "versionone" has a member named "Andre Agile" with an email address of "andre@mailinator.com"
		And "versionone" has a project named "Sample: Release 2.0" with a Reference value of "2000"
		And "Sample: Release 2.0" has a story named "Sample: Field Completion"
		And "Sample: Field Completion" has a task named "Code" with a Reference value of "CC2T-0001"

	Scenario: Reconcile does not show unmatched projects
		Given "clarityppm" has a project called "Big Data"
		And "versionone" has a project called "Big Data" with a blank Reference value
		When I run the Project Reconciliation Process
		Then the output file shows me "Big Data" has no associated Clarity PPM project.

	Scenario: Reconcile shows matched projects
		When I run the Project Reconciliation Process
		Then the output file shows me "Sample: Release 2.0" has an associated Clarity PPM project with the name "Call Center Release 2.0".

	Scenario: Reconcile does not show unmatched users
		Given "clarityppm" has a resource named "Niku Administrator" with an email address of "v1clarityppm@mailinator.com"
		And "versionone" has a member named "Administrator" with a blank email address
		When I run the Member Reconciliation Process
		Then the output file shows me "Administrator" has no associated Clarity PPM resource.

	Scenario: Reconcile shows matched users
		When I run the Member Reconciliation Process
		Then the output file shows me "Andre Agile" row has an associated Clarity PPM resource with the name "Andre Agile".

	Scenario: Reconcile ignores tasks with no ID
		Given "Call Center Release 2.0" has a task named "Team Building" with no ID
		When I run the Task Reconciliation Process
		Then the output file shows me "Team Building" does not appear in any row as an associated Clarity PPM task.

	Scenario: Reconcile does not show unmatched tasks
		Given "Sample: Field Completion" has a task named "Design" with no Reference value
		When I run the Task Reconciliation Process
		Then the output file shows me "Design" has no associated Clarity PPM task.

	Scenario: Reconcile shows matched tasks
		When I run the Task Reconciliation Process
		Then the output file shows me "Code" has an associated Clarity PPM task with the name "Field Completion Coding".
