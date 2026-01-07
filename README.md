![RgGen](logo/rggen.png)

[![Gem Version](https://badge.fury.io/rb/rggen.svg)](https://badge.fury.io/rb/rggen)
[![Docker Pulls](https://img.shields.io/docker/pulls/rggendev/rggen-docker?logo=docker)](https://hub.docker.com/r/rggendev/rggen-docker)
[![Homebrew Formula Downloads](https://img.shields.io/homebrew/installs/dy/rggen?logo=homebrew)](https://formulae.brew.sh/formula/rggen)

[![CI](https://github.com/rggen/rggen/workflows/CI/badge.svg)](https://github.com/rggen/rggen/actions?query=workflow%3ACI)
[![Maintainability](https://qlty.sh/badges/a82c7d7a-e35c-4425-8d7e-26b3d09f587a/maintainability.svg)](https://qlty.sh/gh/rggen/projects/rggen)
[![codecov](https://codecov.io/gh/rggen/rggen/branch/master/graph/badge.svg)](https://codecov.io/gh/rggen/rggen)
[![Discord](https://img.shields.io/discord/1406572699467124806?style=flat&logo=discord)](https://discord.com/invite/KWya83ZZxr)

[![ko-fi](https://www.ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/A0A231E3I)

# RgGen

RgGen is a code generation tool for ASIC/IP/FPGA/RTL engineers. It will automatically generate source code related to control and status registers (CSR), e.g. SytemVerilog RTL, UVM register model (UVM RAL/uvm_reg), C header file, Wiki documents, from human readable register map specifications.

RgGen has following features:

* Generate source files related to CSR from register map specifications
    * RTL module
        * SystemVerilog
        * Verilog
            * Need [rggen-verilog](https://github.com/rggen/rggen-verilog) plugin
        * [Veryl](https://veryl-lang.org)
            * Need [rggen-veryl](https://github.com/rggen/rggen-veryl) plugin
        * VHDL
            * Need [rggen-vhdl](https://github.com/rggen/rggen-vhdl) plugin
        * Supports standard bus protocols
            * AMBA APB
            * AMBA AXI4-Lite
            * Avalon-MM
            * Wishbone
    * UVM register model (UVM RAL/uvm_reg)
    * C header file
    * Register map documents written in Markdown
* Register map specifications can be written in human readable format
    * Ruby with APIs to describe register map information
    * YAML
    * JSON
    * TOML
    * Spreadsheet (XLSX, ODS, CSV)
* Plugin feature
    * Allow you to customize RgGen for your environment
        * Add your own special bit field types
        * Add your own host bus protocol

## Installation

### Ruby

RgGen is written in the [Ruby](https://www.ruby-lang.org/en/about/) programing language and its required version is 3.1 or later. You need to install any of these versions of Ruby before installing RgGen tool. To install Ruby, see [this page](https://www.ruby-lang.org/en/documentation/installation/).

### Installation Command

RgGen depends on following sub components and other Ruby libraries.

* [rggen-core](https://github.com/rggen/rggen-core)
* [rggen-default-register-map](https://github.com/rggen/rggen-default-register-map)
* [rggen-systemverilog](https://github.com/rggen/rggen-systemverilog)
* [rggen-c-header](https://github.com/rggen/rggen-c-header)
* [rggen-markdown](https://github.com/rggen/rggen-markdown)
* [rggen-spreadsheet-loader](https://github.com/rggen/rggen-spreadsheet-loader)

To install RgGen and the dependencies, use the command below:

```
$ gem install rggen
```

RgGen and dependencies will be installed on your system root.

If you want to install them on other location, you need to specify install path and set `GEM_PATH` and `PATH` environment variables:

```
$ gem install --install-dir /path/to/your/install/directory rggen
$ export GEM_PATH=/path/to/your/install/directory
$ export PATH=$GEM_PATH/bin:$PATH
```

You would get the following error message duaring installation if you have the old RgGen (version < 0.9).

```
ERROR:  Error installing rggen:
        "rggen" from rggen-core conflicts with installed executable from rggen
```

To resolve the above error, there are three solutions.
See [this page](https://github.com/rggen/rggen/wiki/Resolve-Confliction-of-Installed-Executable)

### Docker Image

The [rggen-docker](https://hub.docker.com/r/rggendev/rggen-docker) is a Docker image to simplify installation and use of RgGen.
You can also execute RgGen by using this image:

```
$ docker run -ti --rm -v ${PWD}:/work --user $(id -u):$(id -g) rggendev/rggen-docker:latest -c config.yml -o out block_0.yml
```

See the [rggen-docker repository](https://github.com/rggen/rggen-docker) for further details.

### Homebrew Installation

On macOS or Linux, if [Homebrew](https://brew.sh) is installed, you can install RgGen with this command:

```
brew install rggen
```

This will automatically install Ruby if needed, and will provide RgGen itself as well as the [VHDL](https://github.com/rggen/rggen-vhdl), [Verilog](https://github.com/rggen/rggen-verilog), and [Veryl](https://github.com/rggen/rggen-very) plugins.

## Usage

See [Wiki documents](https://github.com/rggen/rggen/wiki).

## Plugin

RgGen has `plugin` feature to allow your cusomization.
See [this Wiki document](https://github.com/rggen/rggen/wiki/Create-Your-Own-Plugin) for futher detals.

## Supported Tools

Following EDA tools can accept the generated source files.

* Simulation tools
    * Synopsys VCS
    * Cadence Xcelium
    * Altair DSim
    * AMD Vivado Simulator
    * Verilator
        * Need `-Wno-unoptflat` switch for Verilog RTL
    * Icarus Verilog
        * Verilog RTL only
* Synthesis tools
    * Synopsys Design Compiler
    * Intel Quartus
    * AMD Vivado
    * [Yosys](http://www.clifford.at/yosys/)
        * Verilog RTL

## Example

You can get sample configuration file and register map specification from the [rggen-sample](https://github.com/rggen/rggen-sample) repository.
This register map specification is for a UART IP.

* Configuration file
    * https://github.com/rggen/rggen-sample/blob/master/config.yml
* Register map specification
    * https://github.com/rggen/rggen-sample/blob/master/uart_csr.yml

You can try to use RgGen by uisng these example files. Hit command below:

```
$ rggen -c config.yml -o out uart_csr.yml
```

* `-c`: Specify path to your configuration file
* `-o`: Specify path to the directory where generated files will be written to

Then, generated files will be written to the `out` directory.

If you want to generate Verilog RTL, Veryl RTL and VHDL RTL then you need to instll optional plugins listed below.

* Verilog writer plugin: [rggen-verilog](https://github.com/rggen/rggen-verilog)
* Veryl writer plugin: [rggen-veryl](https://github.com/rggen/rggen-veryl)
* VHDL writer plugin: [rggen-vhdl](https://github.com/rggen/rggen-vhdl)

```
$ gem install rggen-verilog
$ gem install rggen-veryl
$ gem install rggen-vhdl
```

In addition, you need to tell RgGen to use these plugins by using the `--plugin` option switch:

```
$ rggen -c config.yml --plugin rggen-verilog --plugin rggen-veryl --plugin rggen-vhdl uart_csr.yml
```

RgGen will generate following source files from the [`uart_csr.yml`](https://github.com/rggen/rggen-sample/blob/master/uart_csr.yml) register map specification:

* SystemVerilog RTL
    * https://github.com/rggen/rggen-sample/blob/master/uart_csr.sv
    * https://github.com/rggen/rggen-sample/blob/master/uart_csr_rtl_pkg.sv
* Verilog RTL
    * https://github.com/rggen/rggen-sample/blob/master/uart_csr.v
    * https://github.com/rggen/rggen-sample/blob/master/uart_csr.vh
* Veryl RTL
    * https://github.com/rggen/rggen-sample/blob/master/uart_csr.veryl
* VHDL RTL
    * https://github.com/rggen/rggen-sample/blob/master/uart_csr.vhd
* UVM register model
    * https://github.com/rggen/rggen-sample/blob/master/uart_csr_ral_pkg.sv
* C header file
    * https://github.com/rggen/rggen-sample/blob/master/uart_csr.h
* Markdown document
    * https://github.com/rggen/rggen-sample/blob/master/uart_csr.md

## Contributing

See [Contributing Guide](CONTRIBUTING.md).

## Contact

Feedbacks, bug reports, questions and etc. are wellcome! You can post them by using following ways:

* [GitHub Issue Tracker](https://github.com/rggen/rggen/issues)
* [GitHub Discussions](https://github.com/rggen/rggen/discussions)
* [Discord](https://discord.com/invite/KWya83ZZxr)
* [Mailing List](https://groups.google.com/d/forum/rggen)
* [Mail](mailto:rggen@googlegroups.com)

## See Also

* https://github.com/rggen/rggen-core
* https://github.com/rggen/rggen-default-register-map
* https://github.com/rggen/rggen-systemverilog
* https://github.com/rggen/rggen-c-header
* https://github.com/rggen/rggen-markdown
* https://github.com/rggen/rggen-spreadsheet-loader
* https://github.com/rggen/rggen-verilog
* https://github.com/rggen/rggen-veryl
* https://github.com/rggen/rggen-vhdl
* https://github.com/rggen/rggen-docker

## Copyright & License

Copyright &copy; 2019-2026 Taichi Ishitani. RgGen is licensed under the [MIT License](https://opensource.org/licenses/MIT), see [LICENSE](LICENSE) for futher detils.

## Code of Conduct

Everyone interacting in the RgGen project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).
