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
    @logger ||= Logger.new
  end
  def self.logger= logger
    @logger = logger
  end
end
