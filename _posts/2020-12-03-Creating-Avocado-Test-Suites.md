# **Creating Avocado Test Suites** #

We will explore the different ways to create Host Test Suites for avocado tests, via [Avocado Tests Suite](https://github.com/open-power-host-os/tests)

## **What is a Test Suite ?** ##

A way of defining that is, orchestrating multiple tests to run in a way that we want to.
We have many different ways of creating such a test suite. Some of the useful ways we have support for are:

1. Running the same test multiple times.
2. Running the same test multiple times, each at a different time in the test suite.
3. Running a sub-test from an avocado test which consists of multiple tests.
4. Not running a test in a particular environment.
5. Having some tests run in background (done by writing avocado test differently).

The host tests are written in files placed in the directory `config/tests/host/` with the filetype as cfg (ending with .cfg).

The order in which we write the tests in the cfg file is the same order in which the tests are run.

When the same test is run more than once, the iteration of it is appended to the test name, and is displayed in the results as below.

The below example explains the items 1, 2 and 3.

These methods are useful when a test behaves differently based on when / how often it is run or depends on the tests run before it.

Config file
```txt
avocado-misc-tests/io/disk/ssd/nvmetest.py:NVMeTest.test_firmware_upgrade avocado-misc-tests/io/disk/ssd/nvmetest.py.data/nvmetest.yaml
avocado-misc-tests/io/disk/ssd/nvmetest.py:NVMeTest.testformatnamespace avocado-misc-tests/io/disk/ssd/nvmetest.py.data/nvmetest.yaml
avocado-misc-tests/io/disk/ssd/nvmetest.py:NVMeTest.testformatnamespace avocado-misc-tests/io/disk/ssd/nvmetest.py.data/nvmetest.yaml
avocado-misc-tests/io/disk/ssd/nvmetest.py:NVMeTest.testwrite avocado-misc-tests/io/disk/ssd/nvmetest.py.data/nvmetest.yaml
avocado-misc-tests/io/disk/ssd/nvmetest.py:NVMeTest.testformatnamespace avocado-misc-tests/io/disk/ssd/nvmetest.py.data/nvmetest.yaml
avocado-misc-tests/io/disk/ssd/nvmetest.py:NVMeTest.testformatnamespace avocado-misc-tests/io/disk/ssd/nvmetest.py.data/nvmetest.yaml
```

Output
```bash
15:17:07 INFO    : Summary of test results can be found below:
TestSuite                                                                   TestRun    Summary             
 
host_io_nvme_fvt_nvmetest_NVMeTest_test_firmware_upgrade_nvmetest           Run        Successfully executed
/root/avocado-fvt-wrapper/results/job-2019-06-03T15.17-9abc103/job.log
 
host_io_nvme_fvt_nvmetest_NVMeTest_testformatnamespace_nvmetest             Run        Successfully executed
/root/avocado-fvt-wrapper/results/job-2019-06-03T15.17-2f06dde/job.log
 
host_io_nvme_fvt_nvmetest_NVMeTest_testformatnamespace_nvmetest.2           Run        Successfully executed
/root/avocado-fvt-wrapper/results/job-2019-06-03T15.17-e19013c/job.log

host_io_nvme_fvt_nvmetest_NVMeTest_testwrite_nvmetest                       Run        Successfully executed
/root/avocado-fvt-wrapper/results/job-2019-06-03T15.17-d200131/job.log

host_io_nvme_fvt_nvmetest_NVMeTest_testformatnamespace_nvmetest.3           Run        Successfully executed
/root/avocado-fvt-wrapper/results/job-2019-06-03T15.17-c12fe32/job.log
 
host_io_nvme_fvt_nvmetest_NVMeTest_testformatnamespace_nvmetest.4           Run        Successfully executed
/root/avocado-fvt-wrapper/results/job-2019-06-03T15.17-39601c5/job.log
```

There are environments defined in the [no_run_tests file](https://github.ibm.com/ltctest/avocado-fvt-wrapper/blob/master/config/wrapper/no_run_tests.conf).

They can be used to specify tests which we have in the cfg files, but do not want to run on specific environments.

This is useful when a test is not supported or has a known bug on some environments.
