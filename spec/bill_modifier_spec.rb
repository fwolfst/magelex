require 'spec_helper'

describe Magelex::BillModifier do
  describe '#adjust_order_number' do
    it 'strips leading "e-" from order_nr' do
      bill = Magelex::LexwareBill.new(order_nr: 'e-417')
      Magelex::BillModifier.adjust_order_number(bill)
      expect(bill.order_nr).to eq "417"
      bill = Magelex::LexwareBill.new(order_nr: '418')
      Magelex::BillModifier.adjust_order_number(bill)
      expect(bill.order_nr).to eq "418"
    end
  end
end

