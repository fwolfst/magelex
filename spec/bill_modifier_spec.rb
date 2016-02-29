require 'spec_helper'

describe Magelex::BillModifier do
  describe '#process' do
    it 'accepts single bill as argument' do
      bill = Magelex::LexwareBill.new(order_nr: 'e-417')
      Magelex::BillModifier.process bill
    end
    it 'accepts a list of bills as argument' do
      bills = [Magelex::LexwareBill.new(order_nr: 'e-417'),
               Magelex::LexwareBill.new(order_nr: 'e-418')]
      Magelex::BillModifier.process bills
    end
  end

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

  describe '#swissify' do
    it 'does nothing if bill not swiss' do
      bill = Magelex::LexwareBill.new shipping_cost: 12, total_19: 2
      expect(bill.total_19).to eq 2
      expect(bill.total_0).to eq 0
      Magelex::BillModifier.swissify bill
      expect(bill.total_19).to eq 2
      expect(bill.total_0).to eq 0
    end

    it 'puts all total into total_0 if swiss' do
      bill = Magelex::LexwareBill.new shipping_cost: 12,
        total:   7,
        total_0: 6,
        total_7: 0,
        total_19: 0,
        shipping_cost: 1,
        country_code: 'CH'
      Magelex::BillModifier.swissify bill
      Magelex::BillModifier.process_shipping_costs bill
      expect(bill.total_19).to eq 0
      expect(bill.total_7).to eq 0
      expect(bill.total_0).to eq 7
      expect(bill.check).to eq true
    end

    it 'puts wrongly accounted taxed items on incorrect_tax attribute' do
      bill = Magelex::LexwareBill.new shipping_cost: 12,
        total:    19,
        total_0:   9,
        total_7:   0,
        total_19: 10,
        country_code: 'CH'
      Magelex::BillModifier.swissify bill
      expect(bill.total_19).to eq 0
      expect(bill.total_7).to eq 0
      expect(bill.total_0).to eq (9 + 10 / 1.19)
      expect(bill.incorrect_tax).to eq (10 - 10 / 1.19)
      expect(bill.check_diff).to eq 0
      expect(bill.check).to eq true
    end
  end

  describe '#process_shipping_costs' do
    it 'adds the shipping cost (*1.19) to total_19 and tax to tax_19' do
      bill = Magelex::LexwareBill.new shipping_cost: 12, total_19: 2
      expect(bill.total_19).to eq 2
      expect(bill.shipping_cost).to eq 12
      Magelex::BillModifier.process_shipping_costs bill
      expect(bill.total_19).to eq 16.28
      expect(bill.tax_19.round(2)).to eq 2.28
      expect(bill.shipping_cost).to eq 12
    end
    it 'keeps zero tax for shippings to switzerland' do
      bill = Magelex::LexwareBill.new shipping_cost: 12, total_0: 2, country_code: 'CH'
      expect(bill.total_19).to eq 0
      expect(bill.shipping_cost).to eq 12
      Magelex::BillModifier.process_shipping_costs bill
      expect(bill.total_0).to eq 14
      expect(bill.total_19).to eq 0
      expect(bill.tax_19).to eq 0
      expect(bill.shipping_cost).to eq 12
    end
  end
end

