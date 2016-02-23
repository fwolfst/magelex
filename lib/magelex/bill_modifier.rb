module Magelex
  module BillModifier
    def self.process bill
      # 'Trick' around with bill
      swissify bill
      process_shipping_costs bill
      adjust_order_number bill
    end

    def self.process_shipping_costs bill
      if bill.swiss?
        bill.total_0 += LexwareBill.floor2(bill.shipping_cost)
      else
        bill.tax_19 += bill.shipping_cost * 0.19
        bill.total_19 += LexwareBill.floor2(bill.shipping_cost * 1.19)
      end
    end

    def self.adjust_order_number bill
      bill.order_nr.to_s.gsub!(/^e-/, '')
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
  end
end
