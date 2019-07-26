[![Build Status](https://travis-ci.org/rggen/rggen.svg?branch=master)](https://travis-ci.org/rggen/rggen)
[![Maintainability](https://api.codeclimate.com/v1/badges/5ee2248300ec0517e597/maintainability)](https://codeclimate.com/github/rggen/rggen/maintainability)
[![codecov](https://codecov.io/gh/rggen/rggen/branch/master/graph/badge.svg)](https://codecov.io/gh/rggen/rggen)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=rggen_rggen&metric=alert_status)](https://sonarcloud.io/dashboard?id=rggen_rggen)

# RgGen

RgGen is a code generation tool for ASIC/IP/FPGA/RTL engineers. It will automatically generate soruce code related to control/status registers (CSR), e.g. SytemVerilog RTL, UVM RAL model, from human readable register map documents.

## Installation

### Ruby

RgGen is written in the [Ruby](https://www.ruby-lang.org/en/about/) programing language and its required version is 2.3 or later. You need to install  any of these versions of Ruby before installing RgGen tool. To install Ruby, see [this page](https://www.ruby-lang.org/en/downloads/).

### Installatin Command

To isnstall RgGen and necessary libraries, use this command:

```
$ gem install rggen
```

RgGen and libraries will be installed on your system root.

If you want to install them on other location, you need to specify install path and set the `GEM_PATH` environment variable:

```
$ gem install --install-dir YOUR_INSTALL_DIRECTORY rggen
$ export GEM_PATH=YOUR_INSTALL_DIRECTORY
```

## Usage

See [Wiki documents](https://github.com/rggen/rggen/wiki).

## Contact

Feedbacks, bug reports, questions and etc. are wellcome! You can post them by using following ways:

* [GitHub Issue Tracker](https://github.com/rggen/rggen/issues)
* [Mail](mailto:taichi730@gmail.com)

## Copyright & License

Copyright &copy; 2019 Taichi Ishitani. RgGen is licensed unther the [MIT License](https://opensource.org/licenses/MIT), see [LICENSE](LICENSE) for futher detils.

## Code of Conduct

Everyone interacting in the Rggen project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rggen/rggen/blob/master/CODE_OF_CONDUCT.md).
