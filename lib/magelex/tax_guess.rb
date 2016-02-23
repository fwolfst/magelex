module Magelex
  module TaxGuess
    # Guesses the tax category.
    # Question is: how many percent of total is tax_amount.
    def self.guess(total, tax_amount)
      if total == 0 && tax_amount == 0
        return :empty_item
      end
      if total == 0
        raise "TaxGuess: Cannot guess tax of "\
          "#{total}/#{tax_amount} (#{total - total/tax_amount})"
      end

      # net: netto, gro: gross/brutto
      # gro_price = net_price + taxes         ## (1: net_price = gro_price - taxes)
      # gro_price = net_price + net_price * tax_perce
      # tax_perce = (gro_price - net_price) / net_price
      # tax_perce = gro_price / net_price - 1 ## (see 1)
      percentage = total.to_f / (total - tax_amount) - 1

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
