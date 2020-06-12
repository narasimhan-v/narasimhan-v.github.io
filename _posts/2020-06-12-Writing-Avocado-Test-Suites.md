# Writing Avocado Test Suites #

We will explore the ways to write and run Test Suites for avocado tests, via [Avocado Tests Suite](https://github.com/open-power-host-os/tests)

**What is a Test Suite ?**

A way of defining that is, orchestrating multiple tests to run in a way that we want to.

It is not just running multiple tests, but making them run in a way that is
1. Consistent with how every other tests are run
2. Controlled by what the other tests do to the system
3. Handling various options that can be specific to each test

I used the word orchestrating, so that we can compare this with a various musicians in a music orchestra or various dancers in a dance group choreographed.

***Test Suite is not just running multiple tests, but much more than that.***

Please get accustomed to [Avocado basics - prerequisite](#basics-of-avocado---prerequisites)


## Running multiple tests - existing ways ##
There are many tests in the Avocado Tests repository to serve as an example.
The question to people who use them is, how do we run many tests ?
There were only 2 ways of achieving that. **Avocado native** way, or **bash** way.

### Avocado native way ###
Avocado supports running multiple tests, provided they have common options.
```
avocado run test1 test2
avocado run test1 test2 options
```
But we can not provide separate options to each test.
Say, `avocado run test1 test2 -m yaml1 yaml2` is not possible.
Variants in both yamls serve both tests, which is not ideally what we want.

### Bash way ###
`avocado run test1; avocado run test2 -m yaml2; ...`

* But what do we do if we need to edit the yaml before running the test ?
* What if we need the results to be clubbed together ?
* What if we want to make the list of tests more dynamic ?
Which brings us to the conclusion, these ways are not good enough for Test Suites.


## Avocado Test Suites ##

[Avocado Tests Suite](https://github.com/open-power-host-os/tests) is a project that orchestrates avocado tests.

This is a highly capable project that has many of the much needed features for avocado test orchestration.

To name a few:
* Support for both [host](https://github.com/avocado-framework-tests/avocado-misc-tests) and [guest tests](https://github.com/avocado-framework/avocado-vt)
* True orchestration - run a test multiple times, maintain order of tests
* Result summary for every on test suite run
* Run multiple test suites at once
* Individual test case validation and invalidation
* Yaml based input for every test and editing them based in input file
* Support for avocado options specific to one test
* System environment based controls to take care of prerequisites software packages installation
* Easily sharable test suite
* And many more

### Setting up Avocado Test Suite project ###

Very simple:
```
# git clone https://github.com/open-power-host-os/tests
# cd tests
# ./avocado-setup.py --bootstrap
07:51:27 INFO    : Check for environment
07:51:27 INFO    : Creating temporary mux dir
07:51:27 INFO    : Creating Avocado Config
07:51:27 INFO    : Bootstrapping Avocado
07:51:27 INFO    : Cloning the repo: avocado in /root/sim/tests/avocado
07:51:30 INFO    : Installing avocado from /root/sim/tests/avocado
07:51:36 INFO    : Cloning the repo: avocado-misc-tests in /root/sim/tests/tests/avocado-misc-tests
07:51:40 WARNING : Avocado varianter_yaml_to_mux plugin not installed
07:51:40 INFO    : Installing optional plugin: varianter_yaml_to_mux
07:51:41 INFO    : Removing temporary mux dir
```
Read the [documentation](https://github.com/open-power-host-os/tests/blob/master/README.md) for more understanding.

### Creating a Test Suite ###

Test Suite is in a text file format.

sample.cfg
```
test1
test2 yaml2
test3
test4 "options"
test5 yaml5 "options"
```

[Actual Example](https://github.com/open-power-host-os/tests/blob/master/config/tests/host/example.cfg)

Notice it is placed in a folder structure like `config/tests/host`, meaning it is a host test config file.
References of testsuite and test config are the same, in this context.

### Running a Test Suite ###

`./avocado-setup.py --run-suite <type>_<test_suite_file_name>`

Multiple test suites are run like:

`./avocado-setup.py --run-suite <type1>_<test_suite_file_name1>,<type2>_<test_suite_file_name2>,..`

In our case, it would be `./avocado-setup.py --run-suite host_sample`


### Providing inputs to the yaml ###

There is a concept of input file, which is in a config file format.
Use this option to specify input file for custom yaml file values for host tests.
This is a config file format, with config section indicating the test cfg file name, and the key value pairs indicating the yaml parameter to be changed and its corresponding value, respectively.
This is used as:
`./avocado-setup.py --run-suite <testsuite> --input-file <input_file_path>`

Consider our sample.cfg.

The yamls there are yaml2 and yaml5

yaml2:
```
a: 1
b:
c: 3
```

yaml5:
```
a: 1
b:
d: 4
e: "this is e"
```

Our input file should look like:
```
[sample]
a = 5
e = "This is E"
f = 100
```

What happens here is:
* value of a in yaml2 and yaml5 are changed to 5
* value of e in yaml5 is changed to "This is E". This is because it exists only in yaml5.
* value of f is not used, since it is not present in any yaml.

So, when we run the suite, `./avocado-setup.py --run-suite host_sample --input-file input_file.txt`
we will have temporary yamls getting created in `/tmp/mux/` folder.

/tmp/mux/yaml2:
```
a: 5
b:
c: 3
```

/tmp/mux/yaml5:
```
a: 5
b:
d: 4
e: "This is E"
```

[Actual Example](https://github.com/open-power-host-os/tests/blob/master/input_example.txt)


## References ##

### Basics of avocado - prerequisites ###

[Avocado](https://github.com/avocado-framework/avocado) is a test framework based on python unittest framework.

[Avocado Tests](https://github.com/avocado-framework-tests/avocado-misc-tests) is a collection of avocado based tests.
They can be run via `avocado run test`. There are many options to it, the most famous one being providing input via multiplexing yaml files: 
`avocado run test -m yaml`.
