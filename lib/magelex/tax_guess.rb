module Magelex
  module TaxGuess
    def self.guess(total, tax_amount)
      if total == 0 && tax_amount == 0
        return :empty_item
      end
      if total == 0
        raise "TaxGuess: Cannot guess tax of "\
          "#{total}/#{tax_amount} (#{total - total/tax_amount})"
      end
      percentage = total.to_f / (total - tax_amount) - 1
      puts percentage
      case percentage
        when -0.01..0.01
          :tax0
        when 0.06..0.09
          :tax7
        when 0.16..0.20
          :tax19
        else
          raise "TaxGuess: Cannot guess tax of "\
            "#{total}/#{tax_amount} (#{total - total/tax_amount}) - #{tax_amount/total if total != 0}"
      end
    end
  end
end
