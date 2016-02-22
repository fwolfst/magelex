require 'magelex'

module Magelex
  class LexwareBill
    @@EU_CODES = ['BE','BG','CZ','DK','EE','EL','ES','FR',
                  'IE','IT','CY','LV','LT','LU','HU','MT',
                  'NL','AT','PL','PT','RO','SI','SK','FI','SE','UK']

    attr_accessor :order_nr, :customer_name, :country_code,
      :date, :status, :shipping_cost, :total, :total_0, :total_7, :total_19, :has_problems, :tax_7, :tax_19, :incorrect_tax

    def initialize values={}
      @total_0, @total_7, @total_19, @total = 0, 0, 0, 0
      @customer_name = values.delete(:customer_name) || ""
      @order_nr = values.delete(:order_nr) || nil
      @date     = values.delete(:date)  || nil
      @total    = values.delete(:total) || 0
      @total_0  = values.delete(:total_0)  || 0
      @total_7  = values.delete(:total_7)  || 0
      @total_19 = values.delete(:total_19) || 0
      @tax_7    = values.delete(:tax_7)  || 0
      @tax_19   = values.delete(:tax_19) || 0
      @incorrect_tax = values.delete(:incorrect_tax) || 0
      @status   = values.delete(:status) || nil
      @shipping_cost = values.delete(:shipping_cost) || nil
      @country_code  = values.delete(:country_code)  || nil
      @has_problems  = false
      if !values.empty?
        raise "Unknown values for bill: #{values.inspect}"
      end
    end

    def swiss?
      @country_code == 'CH'
    end

    # Add item values to corresponding total_ and tax_ attributes
    # depending on discount, include or exclude taxes.
    def add_item amount, tax, name, discount=0
      begin
        case TaxGuess.guess(amount, tax)
        when :tax0
          @total_0 += amount.round(2)
        when :tax7
          if discount != 0
            @total_7 += (amount.round(2) * 1.07)
          else
            @total_7 += amount.round(2)
          end
          @tax_7 += tax
        when :tax19
          if discount != 0
            @total_19 += (amount.round(2) * 1.18)
          else
            @total_19 += amount.round(2)
          end
          if swiss?
            Magelex::logger.info("19% Tax Item in swiss order: #{@order_nr}: #{name}")
          end
          @tax_19 += tax
        when :empty_item
          Magelex::logger.debug("Empty item: '#{name}' #{amount}, tax: #{tax}")
        end
      rescue RuntimeError
        Magelex::logger.warn("Unguessable tax (#{@order_nr}: #{name} #{amount}/#{tax})")
        @has_problems = true
      end
    end

    def customer_lastname
      @customer_name.split[-1]
    end

    def in_eu?
      @@EU_CODES.include? @country_code
    end

    def check
      @has_problems == false && @total > 0 && @total.round(2) == (@total_0.round(2) + @total_7.round(2) + @total_19.round(2)).round(2)
    end

    def self.floor2 value
      (value * 100).to_i / 100.0
    end

    def process_shipping_costs
      if swiss?
        @total_0 += LexwareBill.floor2(@shipping_cost)
      else
        @tax_19 += @shipping_cost * 0.19
        @total_19 += LexwareBill.floor2(@shipping_cost * 1.19)
      end
    end

    def complete?
      @status == "complete"
    end

    # Should be called before 'process_shipping_costs'
    def swissify
      return if !swiss?

      @incorrect_tax += @total_19 - @total_19 / 1.19
      @incorrect_tax += @total_7 - @total_7 / 1.07
      @total_0 += @total_19 / 1.19
      @total_19 = 0
      @total_0 += @total_7 / 1.07
      @total_7 = 0
    end
  end
end
