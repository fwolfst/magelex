require 'magelex'

module Magelex
  class LexwareBill
    @@EU_CODES = ['BE','BG','CZ','DK','EE','EL','ES','FR',
                  'IE','IT','CY','LV','LT','LU','HU','MT',
                  'NL','AT','PL','PT','RO','SI','SK','FI','SE','UK']

    attr_accessor :order_nr, :customer_name, :country_code,
      :date, :status, :shipping_cost, :total, :total_0, :total_7, :total_19

    def initialize
      @total_0, @total_7, @total_19, @total = 0, 0, 0, 0
    end

    def swiss?
      @country_code == 'CH'
    end

    def add_item amount, tax, name
      case TaxGuess.guess(amount, tax)
      when :tax0
        @total_0 += amount
      when :tax7
        @total_7 += amount
      when :tax19
        @total_19 += amount
      else
        raise 'Unknown Tax class'
      end
    end

    def customer_lastname
      @customer_name.split[-1]
    end

    def in_eu?
      @@EU_CODES.include? @country_code
    end
  end
end
