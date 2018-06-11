module Magelex
  module BillModifier
    # shifts to total_0 for swiss orders,
    # consumes the shipping cost (19)
    # and adjusts the order number
    # takes single bill or list of bills
    def self.process bills
      [*bills].each do |bill|
        fix_shipping_costs bill
        swissify bill
        process_shipping_costs bill
        adjust_order_number bill
        remove_herr_frau_name bill
      end
    end

    def self.process_shipping_costs bill
      if bill.swiss?
        bill.total_0 += bill.shipping_cost
      else
        bill.tax_19 += bill.shipping_cost * 0.19
        bill.total_19 += (bill.shipping_cost * 1.19)
      end
    end

    def self.adjust_order_number bill
      bill.order_nr.to_s.gsub!(/^e-/, '')
    end

    def self.fix_shipping_costs bill
      if (12.59..12.61).include? bill.shipping_cost
        Magelex::logger.info "Correcting shipping cost of #{bill.order_nr} (12.6 -> 15 / 1.19 €)" if bill.complete?
        bill.shipping_cost = 15 / 1.19
      elsif bill.shipping_cost == 4.15
        Magelex::logger.info "Correcting shipping cost of #{bill.order_nr} (4.15 -> 4.95 / 1.19 €)" if bill.complete?
        bill.shipping_cost = 4.95 / 1.19
      end
    end

    # total0 consumes total and resets others, if check passes
    # shipping costs should be consumed before
    # this has to be layed out in a graph or documented properly
    # (what happens when)
    def self.swissify bill
      return if !bill.swiss?

      bill.incorrect_tax += (bill.total_19 - bill.total_19 / 1.19)
      bill.incorrect_tax += (bill.total_7  - bill.total_7 / 1.07)
      bill.total_0 += (bill.total_19 / 1.19)
      bill.total_19 = 0
      bill.total_0 += (bill.total_7 / 1.07)
      bill.total_7 = 0
    end

    def self.remove_herr_frau_name bill
      bill.customer_name.gsub!(/^Herr /, '')
      bill.customer_name.gsub!(/^Frau /, '')
    end

  end
end
