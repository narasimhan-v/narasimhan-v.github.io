# Importance of Log capturing #

Log capturing is very important when we run tests. It helps us to understand how the system behaves. More so in case of test failures, where we need to log certain files to understand why.

### Logging capabilities of Avocado ###

The logging capabilities of avocado are quite extensive.
* files - mainly sysfs files, and certain other files useful, captured before and after the test
* commands - command output run before and after the test
* profilers - runs these commands in background during the test

All of the above are captured into results folder. They are defined in avocado.conf, and can be customised.

```
# ls /root/avocado/job-results/latest/test-results/2-examples_tests_failtest.py_FailTest.test/sysinfo/pre/
 cmdline              'df -mP'    'gcc --version'   interrupts      lscpu          modules                    partitions         slabinfo    version
 cpuinfo               dmesg       hostname        'ip link'       'lspci -vvnn'   mounts                     scaling_governor  'uname -a'
 current_clocksource  'fdisk -l'  'ifconfig -a'    'ld --version'   meminfo       'numactl --hardware show'   sched_features     uptime

# ls /root/avocado/job-results/latest/test-results/2-examples_tests_failtest.py_FailTest.test/sysinfo/post/
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


### Optimisations ###

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

By this, we are looking atmost 35 % less disk space consumption in results folder per test, with less than 1s extra processing time.

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

### Proposed Optimisation ###

There is a proposed optimisation, which should be ready soon: [Collecting certain extra logs in case of test failure](https://github.com/avocado-framework/avocado/issues/3567)
