# Magelex

*This README reflects (more or less) the current development state, for documentation of a given version, see the README shipped with that gem (or respective tag on github).*

Magelex takes Magento online shop order data and presents it in a format that Lexware can read to model open positions.

Aim is to manage the cash flow in Lexware.

The solution is specific for one customers needs.  If you need a similar solution (or have a better one!) contact me!

## Installation

Install it yourself as:

    $ gem install magelex

## Assumptions

Customer accounts are hard coded.  Database access is necessary for date corrections (but can be skipped).

## Usage

Call `magelex --help` to get a basic idea:

    Usage: magelex DIR_OR_FILE
    
    Imports order data from magento csv export, exports this data to be imported to open positions in lexware.
    
        -o, --out-dir DIR                Directory to write output files to.
        -l, --log-file FILE              File to log to (default: STDERR).
        -v, --verbose                    Run verbosely
        -s, --skip-db                    Do not update dates from mysql database.
        -h, --help                       Show this help and exit.
            --version                    Show version and exit.
    

By default, `magelex` will log to `STDERR`, but you can pass the path to a log file.

It consumes a single file (given as argument, as in `magelex magento_orders.csv`) or a directory of files.  `magelex` will create a file with same filename in the path `lexware` (can be changed with the `--out-dir` option).

### Configuration

Configure magento MySQL database access in `magelex.conf` .  An example configuration comes shipped with the gem (`magelex.conf.example`).

If no database queries should be done, invoke with `--skip-db`.

### Use the command line interface

Call `magelex --help` to get a basic idea.

## Documentation of process

`bin/magelex` will read in a CSV file with orders exported by magento (`Magelex::MagentoCSV`).  In this file, one row accounts for one 'order item'.  Items are added up to form a `Magelex::LexwareBill`.  Adding Items to a `LexWareBill` collects the brutto values separated by tax.  For this, the tax category (0%, 7% or 19%) has to be guessed (`Magelex::TaxGuesser`).

Result of this processing are a number of `LexwareBill`s.
Swiss orders require some special attention, so steps are undertaken to adjust these to reality.  Afterwards, the shipping costs can be included.

Finally the `LexwareBill`s that conform to the rules (`LexwareBill#check`) can be exported to be imported to Lexware (`Magelex::LexwareCSV`).

## Changes

  - 0.1.4:
    respect per-item discounts

## Development

After checking out the repo, run `rake spec` to run the tests. You can also run `bundle console` for an interactive prompt that will allow you to experiment. Run `bundle exec magelex` to use the gem in this directory, ignoring other installed copies of this gem.

Generally, I prefer to work and develop in `bundle exec`-mode.

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fwolfst/magelex. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

That said, just get in contact.
