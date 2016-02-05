require 'magelex'

module Magelex
  class LexwareBill
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
  end
end
