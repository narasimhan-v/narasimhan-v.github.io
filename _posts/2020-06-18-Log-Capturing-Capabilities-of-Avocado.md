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



More info [here](https://avocado-framework.readthedocs.io/en/80.0/guides/user/chapters/introduction.html?highlight=sysinfo#sysinfo-collection)
