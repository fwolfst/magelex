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

    def self.for_7 bill
      bill.in_eu? ? '8310' : '8300'
    end

    def self.for_19 bill
      bill.in_eu? ? '8315' : '8400'
    end

    def self.for_0 bill
      '8120'
    end
  end
end
