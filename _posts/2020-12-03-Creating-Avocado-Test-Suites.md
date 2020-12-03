# **Creating Avocado Test Suites** #

We will explore the different ways to create Host Test Suites for avocado tests, via [Avocado Tests Suite](https://github.com/open-power-host-os/tests)

## **What is a Test Suite ?** ##

A way of defining that is, orchestrating multiple tests to run in a way that we want to.
We have many different ways of creating such a test suite. Some of the useful ways we have support for are:

1. Running the same test multiple times
2. Running the same test multiple times, each at a different time in the test suite
3. Running a sub-test from an avocado test which consists of multiple tests
4. Not running a test in a particular environment
5. Having some tests run in background (done by writing avocado test differently)

We have some examples which explains each of these below.

The host tests are written in files placed in the directory `config/tests/host/` with the filetype as cfg (ending with .cfg).

The order in which we write the tests in the cfg file is the same order in which the tests are run.


#### **Example 1** ####

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

These methods are useful when a test behaves differently based on when / how often it is run or depends on the tests run before it.

When the same test is run more than once, the iteration of it is appended to the test name, and is displayed in the results as below.

#### **Example 2** ####

There are environments defined in the [no_run_tests file](https://github.ibm.com/ltctest/avocado-fvt-wrapper/blob/master/config/wrapper/no_run_tests.conf).

They can be used to specify tests which we have in the cfg files, but do not want to run on specific environments.

```
[norun_distro1]
tests =avocado-misc-tests/generic/stress-ng.py avocado-misc-tests/generic/stress-ng.py.data/stress-ng-cpu.yaml,avocado-misc-tests/generic/stress-ng.py avocado-misc-tests/generic/stress-ng.py.data/stress-ng-io.yaml,avocado-misc-tests/generic/stress-ng.py avocado-misc-tests/generic/stress-ng.py.data/stress-ng-network.yaml,avocado-misc-tests/generic/stress-ng.py avocado-misc-tests/generic/stress-ng.py.data/stress-ng-vm.yaml,avocado-misc-tests/generic/stress-ng.py avocado-misc-tests/generic/stress-ng.py.data/stress-ng-interrupt.yaml,avocado-misc-tests/fs/flail.py
[norun_distro1_kvm]
tests =
[norun_distro2_pHyp]
tests =avocado-misc-tests/io/pci/pci_hotplug.py avocado-misc-tests/io/pci/pci_hotplug.py.data/pci_hotplug.yaml
```
Note: Even partial matches are supported here through pattern matching.

This is useful when a test is not supported or has a known bug on some environments.



#### **Examples 3, 4 and 5** ####

```
avocado-misc-tests/io/disk/htx_block_devices.py:HtxTest.test_start avocado-misc-tests/io/disk/htx_block_devices.py.data/htx_block_devices.yaml
avocado-misc-tests/io/disk/htx_block_devices.py:HtxTest.test_check avocado-misc-tests/io/disk/htx_block_devices.py.data/htx_block_devices.yaml

avocado-misc-tests/tree/master/ras/sosreport.py avocado-misc-tests/tree/master/ras/sosreport.py.data/options.yaml
avocado-misc-tests/ras/supportconfig.py
avocado-misc-tests/io/disk/htx_block_devices.py:HtxTest.test_check avocado-misc-tests/io/disk/htx_block_devices.py.data/htx_block_devices.yaml

avocado-misc-tests/cpu/ppc64_cpu_test.py:PPC64Test.test_smt_loop
avocado-misc-tests/io/disk/htx_block_devices.py:HtxTest.test_check avocado-misc-tests/io/disk/htx_block_devices.py.data/htx_block_devices.yaml

avocado-misc-tests/io/disk/htx_block_devices.py:HtxTest.test_stop avocado-misc-tests/io/disk/htx_block_devices.py.data/htx_block_devices.yaml
```

```
avocado-misc-tests/io/disk/softwareraid.py avocado-misc-tests/io/disk/softwareraid.py.data/softwareraid_setup.yaml
avocado-misc-tests/io/disk/ltp_fs.py avocado-misc-tests/io/disk/ltp_fs.py.data/ltp_fs.yaml
avocado-misc-tests/io/disk/fiotest.py avocado-misc-tests/io/disk/fiotest.py.data/fio.yaml
avocado-misc-tests/io/disk/htx_block_devices.py avocado-misc-tests/io/disk/htx_block_devices.py.data/htx_block_devices.yaml
avocado-misc-tests/io/disk/softwareraid.py avocado-misc-tests/io/disk/softwareraid.py.data/softwareraid_cleanup.yaml
```

```
avocado-misc-tests/io/net/bonding.py:Bonding.test_setup avocado-misc-tests/io/net/bonding.py.data/bonding_single.yaml
avocado-misc-tests/io/net/htx_nic_devices.py:HtxNicTest.test_start avocado-misc-tests/io/net/htx_nic_devices.py.data/htx_nic_devices.yaml
avocado-misc-tests/io/net/htx_nic_devices.py:HtxNicTest.test_check avocado-misc-tests/io/net/htx_nic_devices.py.data/htx_nic_devices.yaml
avocado-misc-tests/io/net/network_test.py:NetworkTest.test_gro avocado-misc-tests/io/net/network_test.py.data/network_test.yaml
avocado-misc-tests/io/net/network_test.py:NetworkTest.test_lro avocado-misc-tests/io/net/network_test.py.data/network_test.yaml
avocado-misc-tests/io/net/network_test.py:NetworkTest.test_promisc avocado-misc-tests/io/net/network_test.py.data/network_test.yaml
avocado-misc-tests/io/net/htx_nic_devices.py:HtxNicTest.test_check avocado-misc-tests/io/net/htx_nic_devices.py.data/htx_nic_devices.yaml
avocado-misc-tests/io/net/htx_nic_devices.py:HtxNicTest.test_stop avocado-misc-tests/io/net/htx_nic_devices.py.data/htx_nic_devices.yaml
avocado-misc-tests/io/net/bonding.py:Bonding.test_cleanup avocado-misc-tests/io/net/bonding.py.data/bonding_single.yaml
```

We also have some tests in avocado which are split into subtests in such a way that there is a start and stop, or, create and delete in those tests.
With that, we can have some tests run in background while others are run in foreground (not exactly, but for explanation purposes).
We can also have some device created on which other tests are run (raid, bond, etc).
Or even a combination of both.
