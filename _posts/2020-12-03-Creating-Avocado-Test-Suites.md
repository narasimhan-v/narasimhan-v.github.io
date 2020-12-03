# Creating Avocado Test Suites #

We will explore the different ways to create Host Test Suites for avocado tests, via [Avocado Tests Suite](https://github.com/open-power-host-os/tests)

**What is a Test Suite ?**

A way of defining that is, orchestrating multiple tests to run in a way that we want to.
We have many different ways of creating such a test suite. Some of the useful ways we have support for are:

1. Running the same test multiple times.

 1a. Running the same test multiple times, each at a different time in the test suite.
2. Running a sub-test from an avocado test which consists of multiple tests.
3. Not running a test in a particular environment
