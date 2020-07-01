### Importance of Log capturing ###

Log capturing is very important when we run tests. It helps us to understand how the system behaves. More so in case of test failures, where we need to log certain files to understand why.

### Logging capabilities of Avocado ###

The logging capabilities of avocado are quite extensive.
* files - mainly sysfs files, and certain other files useful, captured before and after the test
* commands - command output run before and after the test
* profilers - runs these commands in background during the test

All of the above are captured into results folder. They are defined in avocado.conf, and can be customised.

```
# cd latest/test-results/2-examples_tests_failtest.py_FailTest.test/sysinfo/

# ls pre/

 cmdline              'df -mP'    'gcc --version'   interrupts      lscpu          modules                    partitions         slabinfo    version
 cpuinfo               dmesg       hostname        'ip link'       'lspci -vvnn'   mounts                     scaling_governor  'uname -a'
 current_clocksource  'fdisk -l'  'ifconfig -a'    'ld --version'   meminfo       'numactl --hardware show'   sched_features     uptime

# ls post/

cmdline              'df -mP'    'gcc --version'   interrupts     'ld --version'   meminfo  'numactl --hardware show'   sched_features   uptime
 cpuinfo               dmesg       hostname        'ip link'        lscpu           modules   partitions                 slabinfo         version
 current_clocksource  'fdisk -l'  'ifconfig -a'     journalctl.gz  'lspci -vvnn'    mounts    scaling_governor          'uname -a'

```

They are defined in avocado.conf, and can be customised.

```
[sysinfo.collectibles]
# File with list of commands that will be executed and have their output collected
commands = etc/avocado/sysinfo/commands
# File with list of files that will be collected verbatim
files = etc/avocado/sysinfo/files
# File with list of commands that will run alongside the job/test
profilers = etc/avocado/sysinfo/profilers
```

files:
```
/proc/cmdline
/proc/mounts
/proc/pci
```


More info at official [Avocado Sysinfo documentation](https://avocado-framework.readthedocs.io/en/80.0/guides/user/chapters/introduction.html?highlight=sysinfo#sysinfo-collection)


### Optimisation ###

There was a recent optimisation to this, wherein we log only those changed files and commands in post.

If there are 25 files and commands, and 10 of them are unchanged during the test, then it is unnecessary to log them. Also, it is time consuming to locate which files changed, while debugging. So, we log only the 15 files and commands which are changed.

```
# avocado run a.sh
JOB ID     : ea5386a30e8c31f77d880294dcbecdaf2cb5d8e9
JOB LOG    : /root/avocado/job-results/job-2020-06-16T13.45-ea5386a/job.log
 (1/1) a.sh: PASS (5.14 s)
RESULTS    : PASS 1 | ERROR 0 | FAIL 0 | SKIP 0 | WARN 0 | INTERRUPT 0 | CANCEL 0
JOB TIME   : 5.19 s

# ls /root/avocado/job-results/latest/test-results/1-a.sh/sysinfo/pre/
 cmdline              'df -mP'    'gcc --version'   interrupts      lscpu          modules                    partitions      'uname -a'
 cpuinfo               dmesg       hostname        'ip link'       'lspci -vvnn'   mounts                     sched_features   uptime
 current_clocksource  'fdisk -l'  'ifconfig -a'    'ld --version'   meminfo       'numactl --hardware show'   slabinfo         version

# ls /root/avocado/job-results/latest/test-results/1-a.sh/sysinfo/post/
'df -mP'  'ifconfig -a'   interrupts   journalctl.gz   meminfo  'numactl --hardware show'   uptime
```

This behavior is controlled by a parameter in avocado.conf: sysinfo.collect.optimize
```
[sysinfo.collect]
# Optimize sysinfo collection by removing duplicates between pre and post
optimize = False
```

By this, we are looking atmost **35 % less disk space consumption** in results folder per test, depending on the number of sysinfo collectibles configured, with less than **1s extra processing time**.

Without this optimisation:
```
real	0m31.863s
user	0m25.546s
sys	0m1.458s

# du -sh /root/avocado/job-results/latest/
424K	/root/avocado/job-results/latest/
```

With this optimisation:

```
real	0m32.314s
user	0m25.800s
sys	0m1.303s

# du -sh /root/avocado/job-results/latest/
276K	/root/avocado/job-results/latest/
```

### Sysinfo in case of only a test failure ###

There is also another feature which makes it possible to collect certain sysinfo logs only in case of test failure.

This feature gives us the option to collect data like sosreport and supportconfig, that too in case of test failure only.


They are configured via avocado.conf:
```
[sysinfo.collectibles]
fail_commands = etc/avocado/sysinfo/fail_commands
fail_files = etc/avocado/sysinfo/fail_files
```

fail_commands file contents:
```
sosreport --batch --tmp-dir results
supportconfig -t results
```


```
# avocado run avocado/examples/tests/passtest.py avocado/examples/tests/failtest.py
JOB ID     : ac6e7400acbec69f079bd5ab446faa391e2758a9
JOB LOG    : /root/sim/tests/results/job-2020-07-01T14.03-ac6e740/job.log
 (1/2) avocado/examples/tests/passtest.py:PassTest.test: PASS (6.24 s)
 (2/2) avocado/examples/tests/failtest.py:FailTest.test: FAIL: This test is supposed to fail (110.23 s)
RESULTS    : PASS 1 | ERROR 0 | FAIL 1 | SKIP 0 | WARN 0 | INTERRUPT 0 | CANCEL 0
JOB HTML   : /root/sim/tests/results/job-2020-07-01T14.03-ac6e740/results.html
JOB TIME   : 122.93 s


# ls 1-avocado_examples_tests_passtest.py_PassTest.test/sysinfo/post/
'ifconfig -a'   interrupts   journalctl.gz   'multipath -ll'

# ls 2-avocado_examples_tests_failtest.py_FailTest.test/sysinfo/post/
'ifconfig -a'   interrupts   journalctl.gz   'multipath -ll'   'sosreport --batch --tmp-dir results'


# ls -lh results
-rw-------. 1 root root 44M Jul  1 14:05 results/sosreport-ltczzj3-lp2-2020-07-01-yasrjfy.tar.xz
```
