# Magelex

Magelex takes Magento data and presents it in a format that Lexware can read.

Aim is to manage the cash flow in Lexware.

The solution is specific for one customers needs.  If you need a similar solution (or have a better one!) contact me!

## Installation

Install it yourself as:

    $ gem install magelex

## Assumptions

Customer accounts are hard coded.  Database access necessary for date corrections.

## Usage

Call `magelex --help` to get a basic idea.

By default, `magelex` will log to `STDERR`, put you can pass the path to a log file.

It consumes a single file (given as argument, as in `magelex magento_orders.csv`).  `magelex` will create a file with same filename in the path `lexware` (can be changed with the `--out-dir` switch).

### Configuration

Configure magento MySQL database access in `magelex.conf` .  An example configuration comes shipped with the gem (`magelex.conf.example`).

If no database queries should be done, invoke with `--skip-db`.

### Use the command line interface

Call `magelex --help` to get a basic idea.

## Development

After checking out the repo, run `rake spec` to run the tests. You can also run `bundle console` for an interactive prompt that will allow you to experiment. Run `bundle exec magelex` to use the gem in this directory, ignoring other installed copies of this gem.

Generally, I prefer to work and develop in `bundle exec`-mode.

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fwolfst/magelex. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

That said, just get in contact.
