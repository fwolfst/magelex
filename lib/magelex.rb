require 'magelex/version'
require 'magelex/magento_csv'
require 'magelex/lexware_bill'
require 'magelex/lexware_csv'
require 'magelex/tax_guess'
require 'magelex/lexware_account'
require 'magelex/magento_mysql'

require 'logger'

module Magelex
  def self.logger
    @logger ||= Logger.new STDERR
  end
  def self.logger= logger
    @logger = logger
  end

  def self.process_file in_file, out_file, options
    bills_export = []
    # Import/Read file.
    bills = Magelex::MagentoCSV.read in_file
    bills.each do |bill|
      if !bill.complete?
        Magelex.logger.info("Skip order #{bill.order_nr} (incomplete: #{bill.status})")
      else # complete!
        bill.process_shipping_costs
        bill.swissify
        if !bill.check
          Magelex.logger.info("Skip order #{bill.order_nr}#{bill.swiss? ? ' (swiss)' : ''}")
          Magelex.logger.info("  (totals do not match #{bill.total} != "\
                              "(0: #{bill.total_0} + 7: #{bill.total_7} "\
                              "+ 19: #{bill.total_19} "\
                              "= #{bill.total_0 + bill.total_7 + bill.total_19})")
        else
          Magelex.logger.debug("Handle #{bill.order_nr}")
          bills_export << bill
        end
      end
    end

    # Fix dates via database.
    if !options[:skipdb]
      begin
        Magelex.logger.info("Fetching dates from magento mysql.")
        Magelex::MagentoMYSQL.update_dates YAML.load_file('magelex.conf'), bills_export
      rescue => e
        Magelex.logger.error("Could not connect to MySQL database, exiting.")
        Magelex.logger.error(e.inspect)
        exit 2
      end
    else
      Magelex.logger.debug("Skip fetching dates from magento mysql.")
    end

    # Export/Write to file
    if File.exist?(out_file)
      Magelex.logger.error("Output file #{out_file} exists already, exiting.")
      exit 3
    end
    Magelex.logger.info("Writing to #{out_file}")
    Magelex::LexwareCSV.write out_file, bills_export
  end
end
