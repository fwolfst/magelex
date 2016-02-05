module Magelex
  module TaxGuess
    def self.guess(total, tax_amount)
      if tax_amount == 0
        :tax0
      elsif (total - total/1.06) <= tax_amount && (total - total/1.08) >= tax_amount
        :tax7
      elsif (total - total/1.18) <= tax_amount && (total - total/1.20) >= tax_amount
        :tax19
      else
        raise "TaxGuess: Cannot guess tax of "\
          "#{total}/#{tax_amount} (#{total - total/tax_amount})"
      end
    end
  end
end
