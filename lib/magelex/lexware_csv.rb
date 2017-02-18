module Magelex
  module LexwareCSV
    # Writes(renders) to file.
    def self.write file, bills
      File.open(file, 'w') do |f|
        f.write render(bills).gsub("\n", "\r\n").encode(
          'windows-1252', invalid: :replace, undef: :replace)
      end
    end

    def self.to_split_rows bill
      rows = []
      rows << [bill.date.strftime("%d.%m.%Y"),
        bill.order_nr,
        bill.order_and_name,
        bill.total.round(2),
        Magelex::AccountNumber.for_customer(bill),
        0]
      # subs, refactoring needed.
      [:total_0, :total_7, :total_19, :incorrect_tax].each do |part|
        if (amount = bill.send(part)) != 0
          rows << [
                  bill.date.strftime("%d.%m.%Y"),
                  bill.order_nr,
                  bill.order_and_name,
                  amount.round(2),
                  0,
                  Magelex::AccountNumber.for(bill, part),
                  ]
        end
      end
      [:discount_7, :discount_19].each do |part|
        if (amount = bill.send(part)) != 0
          rows << [
                  bill.date.strftime("%d.%m.%Y"),
                  bill.order_nr,
                  bill.order_and_name,
                  - amount.round(2),
                  0,
                  Magelex::AccountNumber.for(bill, part),
                  ]
        end
      end
      rows
    end

    def self.to_single_row bill
      tax_kind = [:total_0, :total_7, :total_19].detect{|t| bill.send(t) > 0}

      [[bill.date.strftime("%d.%m.%Y"),
       bill.order_nr,
       bill.order_and_name,
       bill.total.round(2),
       Magelex::AccountNumber.for_customer(bill),
       Magelex::AccountNumber.for(bill, tax_kind)
       ]]
    end

    def self.to_rows bill
      # split-booking needed?
      if [:total_0, :total_7, :total_19, :incorrect_tax, :discount_7, :discount_19].map{|t| bill.send(t)}.count{|i| i > 0} > 1
        to_split_rows bill
      else
        to_single_row bill
      end
    end

    # Renders into String
    def self.render bills
      CSV.generate(encoding: 'utf-8') do |csv|
        bills.each do |b|
          to_rows(b).each { |r| csv << r }
        end
      end
    end
  end
end
