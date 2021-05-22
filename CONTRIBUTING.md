# Contributing

Your contributions are welcome!

## Bug Report

You can submit bug reports on [GitHub Issue Tracker](https://github.com/rggen/rggen/issues).
Please include information below in your report:

* How to reproduce the bug which you found
    * test code
    * command
* Information about your environment
    * Ruby/RgGen version
    * OS
    * etc.
* Expected result

## Question

Questions are accepted on following channels:

* [GitHub Discussions](https://github.com/rggen/rggen/discussions)
* [GitHub Issue Tracker](https://github.com/rggen/rggen/issues)
* [Gitter Chat Room](https://gitter.im/rggen/rggen)

## Enhancement Request

You can submit your enhancement request on [GitHub Issue Tracker](https://github.com/rggen/rggen/issues).

## Pull Request

You can also submit pull requests on [GitHub Issue Tracker](https://github.com/rggen/rggen/pulls)
to fix the bug which you found or implement enhancements which you want.

1. Fork the repositories which you will change
2. Setup your working environment
    * See the next section
3. Add your change to the repositories
    * You need to add RSpec exmaples if you add new features
    * You need to make sure all existing RSpec examples pass
        * Invoke `rake spec` on the repositry root
4. Make sure all existing RSpec exmaples for other  repositories pass
    * Invoke command below on the working directory
        * `./rggen-devtools/bin/run_all_spec.rb`
5. Commit your changes and submit a pull request

### Setup Working Environment

1. Create a working directory
2. Clone your forked version of the repositories to the working directory
3. Clone following repositories for development tools to the working directory
    * https://github.com/rggen/rggen-devtools
    * https://github.com/rggen/rggen-checkout
4. Clone other RgGen's repositories
    * Invoke commnad below on to the working directory
        * `./rggen-devtools/bin/checkout --list ./rggen-checkout/all.yml --dir .`

```
$ mkdir work
$ cd work
$ git clone git@github.com:yourname/your_repository.git
$ git clone git@github.com:rggen/rggen-devtools.git
$ git clone git@github.com:rggen/rggen-checkout.git
$ ./rggen-devtools/bin/checkout.rb --list ./rggen-checkout/all.yml --dir .
```
