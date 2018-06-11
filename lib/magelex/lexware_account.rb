#encoding: utf-8

module Magelex
  module AccountNumber
    def self.for_customer bill
      first_letter = bill.customer_lastname[0].upcase
      first_letter.gsub!(/[ÖÜÄ]/, 'Ä' => 'A', 'Ö' => 'O', 'Ü' => 'U')

      return 12300 if first_letter == "Y"
      return 12300 if first_letter == "Z"

      # A is 0
      ord = first_letter.ord - "A".ord# + 1
      10000 + ord * 100
    end

    # Get account number for
    # :incorrect_tax, :total_0, :total_7 or :total_19
    def self.for(bill, tax_kind)
      if tax_kind == :total_0
        return for_0 bill
      elsif tax_kind == :total_7
        return for_7 bill
      elsif tax_kind == :total_19
        return for_19 bill
      elsif tax_kind == :incorrect_tax
        return for_incorrect_tax bill
      elsif tax_kind == :discount_0
        return for_discount_0 bill
      elsif tax_kind == :discount_7
        return for_discount_7 bill
      elsif tax_kind == :discount_19
        return for_discount_19 bill
      else
        # its not a tax kind anymore, its a posten type
        raise "unknown tax_kind (#{tax_kind})"
      end
    end

    def self.for_7 bill
      bill.in_eu? ? '8310' : '8300'
    end

    def self.for_19 bill
      bill.in_eu? ? '8315' : '8400'
    end

    def self.for_0 bill
      '8120'
    end

    def self.for_incorrect_tax bill
      '1783'
    end

    def self.for_discount_7 bill
      bill.in_eu? ? '8725' : '8780'
    end

    def self.for_discount_19 bill
      bill.in_eu? ? '8726' : '8790'
    end

    def self.for_discount_0 bill
      bill.in_eu? ? '8726' : '8705'
    end
  end
end
