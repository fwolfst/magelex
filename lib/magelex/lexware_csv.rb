module Magelex
  module LexwareCSV
    def self.write file, bills
    end

    def self.to_rows bill
      # main
      rows = []
      rows << [bill.date.strftime("%d.%m.%Y"),
       bill.order_nr,
       bill.customer_name,
       bill.total,
       Magelex::AccountNumber.for_customer(bill),
       0]
      # subs
      [:total_0, :total_7, :total_19].each do |part|
        if (amount = bill.send(part)) != 0
          rows << [
                  bill.date.strftime("%d.%m.%Y"),
                  bill.order_nr,
                  bill.customer_name,
                  amount,
                  0,
                  Magelex::AccountNumber.for(bill, part),
                  ]
        end
      end
      rows
    end

    def self.render bills
      CSV.generate(encoding: 'utf-8') do |csv|
        bills.each do |b|
          to_rows(b).each { |r| csv << r }
        end
      end
    end
  end
end
