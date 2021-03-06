#encoding: utf-8
require 'csv'

module Magelex
  module MagentoCSV
    MONEY_FIELDS = ['Order Shipping', 'Order Grand Total',
                    'Item Original Price', 'Item Total', 'Item Tax', 'Item Discount']

    CSV::Converters[:german_money_amount] = lambda do |value, info|
      if MONEY_FIELDS.include? info[:header]
        value.gsub(',', '.').to_f
      else
        value
      end
    end

    CSV::Converters[:order_date] = lambda do |value, info|
      if info[:header] == 'Order Date'
        Date.strptime(value[0..10], "%d.%m.%Y")
      else
        value
      end
    end

    # Reads file and returns lexware_bills
    def self.read filename
      self.parse(File.read filename)
    end

    # Creates a bill with basic information from csv line
    def self.init_bill row
      bill = Magelex::LexwareBill.new

      # TODO: defining a attribute|colum- map would be nicer
      bill.order_nr      = row['Order Number']
      bill.customer_name = row['Billing Name']
      bill.country_code  = row['Shipping Country']
      bill.date          = row['Order Date']

      bill.status        = row['Order Status']

      bill.shipping_cost = row['Order Shipping']
      if (12.59..12.61).include? bill.shipping_cost
        Magelex::logger.info "Correcting shipping cost of #{bill.order_nr} (12.6 -> 15 / 1.19 €)" if bill.complete?
        bill.shipping_cost = 15 / 1.19
      elsif bill.shipping_cost == 4.15
        Magelex::logger.info "Correcting shipping cost of #{bill.order_nr} (4.15 -> 4.95 / 1.19 €)" if bill.complete?
        bill.shipping_cost = 4.95 / 1.19
      end
      bill.total         = row['Order Grand Total']
      bill
    end

    def self.parse string
      bills = []
      current_bill = Magelex::LexwareBill.new

      CSV::parse(string, :headers => :first_row,
                 converters: [:all, :german_money_amount, :order_date]) do |row|
        # Multiple rows (with same order_nr) define one order
        # One order will be mapped to one bill
        if current_bill.order_nr != row['Order Number']
          current_bill = init_bill row
        end

        current_bill.add_item(row['Item Total'],
                              row['Item Tax'],
                              row['Item Name'],
                              row['Item Discount'],
                              row['Item Original Price'].to_f * row['Item Qty Ordered'].to_i)

        if !bills.include? (current_bill)
          bills << current_bill
        end
      end
      bills
    end
  end
end
