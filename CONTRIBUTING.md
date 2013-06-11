# Contributing to VersionOne Integration for Clarity PPM

 1. [Getting Involved](#getting-involved)
 2. [Reporting Bugs](#reporting-bugs)
 3. [Contributing Code](#contributing-code)
 4. [Quality Bands](#quality-bands)

## Getting Involved

We need your help to make the VersionOne Integration for Clarity PPM a useful integration. While third-party patches are absolutely essential, they are not the only way to get involved. You can help the project by discovering and [reporting bugs](#reporting-bugs) and helping others on the [versionone-dev group][dev-group] and [GitHub issues][issues].

## Reporting Bugs

Before reporting a bug on the project's [issues page][issues], first make sure that your issue is caused by VersionOne Integration for Clarity PPM, not your application code (e.g. passing incorrect arguments to methods, etc.). Second, search the already reported issues for similar cases, and if it has been reported already, just add any additional details in the comments.

After you made sure that you have found a new bug, here are some tips for creating a helpful report that will make fixing it much easier and quicker:

 * Write a **descriptive, specific title**. Bad: *Problem with filtering*. Good: *Scope.GetThisAndAllChildProjects() always returns an empty list*.
 * Whenever possible, include **Class and Method** info in the description.
 * Create a **simple test case** that demonstrates the bug (e.g. using [NUnit](http://www.nunit.org/)).
 
## Contributing Code

Source code has been exported from Pervasive Data Integrator.

## Quality Bands

Open source software evolves over time. A young project may be little more than some ideas and a kernel of unstable code. As a project matures, source code, UI, tests, and APIs will become more stable. To help consumers understand what they are getting, we characterize every release with one of the following quality bands.

### Seed

The initial idea of a product. The code may not always work. Very little of the code may be covered by tests. Documentation may be sparse. All APIs are considered "private" and are expected to change. Please expect to work with developers to use and maintain the product.

### Sapling

The product is undergoing rapid growth. The code works. Test coverage is on the rise. Documentation is firming up. Some APIs may be public but are subject to change. Please expect to inform developers where information is insufficient to self-serve.

### Mature

The product is stable. The code will continue to evolve with minimum breaking changes. Documentation is sufficient for self-service. APIs are stable.

[dev-group]: http://groups.google.com/group/versionone-dev/
[issues]: https://github.com/versionone/VersionOne.PDI.ClarityPPM/issues