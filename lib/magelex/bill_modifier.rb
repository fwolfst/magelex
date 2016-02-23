module Magelex
  module BillModifier
    def self.process bill
      # 'Trick' around with bill
      # 1. swissify
      # 2. process_shipping_costs
      # adjust order number
      adjust_order_number bill
    end

    def self.adjust_order_number bill
      bill.order_nr.gsub!(/^e-/, '')
    end
  end
end
