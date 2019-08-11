[![Gem Version](https://badge.fury.io/rb/rggen.svg)](https://badge.fury.io/rb/rggen)
[![Build Status](https://travis-ci.org/rggen/rggen.svg?branch=master)](https://travis-ci.org/rggen/rggen)
[![Maintainability](https://api.codeclimate.com/v1/badges/5ee2248300ec0517e597/maintainability)](https://codeclimate.com/github/rggen/rggen/maintainability)
[![codecov](https://codecov.io/gh/rggen/rggen/branch/master/graph/badge.svg)](https://codecov.io/gh/rggen/rggen)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=rggen_rggen&metric=alert_status)](https://sonarcloud.io/dashboard?id=rggen_rggen)
[![Gitter](https://badges.gitter.im/rggen/rggen.svg)](https://gitter.im/rggen/rggen?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

# RgGen

RgGen is a code generation tool for ASIC/IP/FPGA/RTL engineers. It will automatically generate soruce code related to control/status registers (CSR), e.g. SytemVerilog RTL, UVM RAL model, from human readable register map specifications.

RgGen has following features:

* Generate source files related to CSR from register map specifications
    * Source files listed below will be generated:
        * SystemVerilog RTL
        * UVM RAL model
* Register map specifications can be written in human readable format
    * Supported formats are listed below:
        * Ruby with APIs to describe register map information
        * YAML
        * JSON
        * Spreadsheet (XLSX, XLS, OSD, CSV)
* Costomize RgGen for you environment
    * E.g. add special bit field types

## Installation

### Ruby

RgGen is written in the [Ruby](https://www.ruby-lang.org/en/about/) programing language and its required version is 2.3 or later. You need to install  any of these versions of Ruby before installing RgGen tool. To install Ruby, see [this page](https://www.ruby-lang.org/en/downloads/).

### Installatin Command

RgGen depends on [RgGen::Core](https://github.com/rggen/rggen-core), [RgGen::SystemVerilog](https://github.com/rggen/rggen-systemverilog), [RgGen::SpreadsheetLoader](https://github.com/rggen/rggen-spreadsheet-loader) and other Ruby libraries. To install RgGen and dependencies, use the command below:

```
$ gem install rggen
```

RgGen and dependencies will be installed on your system root.

If you want to install them on other location, you need to specify install path and set the `GEM_PATH` environment variable:

```
$ gem install --install-dir YOUR_INSTALL_DIRECTORY rggen
$ export GEM_PATH=YOUR_INSTALL_DIRECTORY
```

You would get the following error message duaring installation if you have the old RgGen (version < 0.9).

```
ERROR:  Error installing rggen:
        "rggen" from rggen-core conflicts with installed executable from rggen
```

To resolve the above error, there are three solutions. See [this page](https://github.com/rggen/rggen/wiki/Resolve-Confliction-of-Installed-Executable)

## Usage

See [Wiki documents](https://github.com/rggen/rggen/wiki).

## Contact

Feedbacks, bug reports, questions and etc. are wellcome! You can post them by using following ways:

* [GitHub Issue Tracker](https://github.com/rggen/rggen/issues)
* [Chat Room](https://gitter.im/rggen/rggen)
* [Mailing List](https://groups.google.com/d/forum/rggen)
* [Mail](mailto:rggen@googlegroups.com)

## See Also

* https://github.com/rggen/rggen-core
* https://github.com/rggen/rggen-systemverilog
* https://github.com/rggen/rggen-spreadsheet-loader

## Copyright & License

Copyright &copy; 2019 Taichi Ishitani. RgGen is licensed unther the [MIT License](https://opensource.org/licenses/MIT), see [LICENSE](LICENSE) for futher detils.

## Code of Conduct

Everyone interacting in the RgGen project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rggen/rggen/blob/master/CODE_OF_CONDUCT.md).
