require 'spec_helper'

describe Magelex::LexwareBill do
  describe '#initialize' do
    it 'can be initialized' do
      expect(Magelex::LexwareBill.new).not_to be nil
    end

    it 'can be initialized with values' do
      bill = Magelex::LexwareBill.new customer_name: "Hugo Harm",
        order_nr: 2039132,
        date: "12.12.2012",
        total: 192083,
        total_0: 13,
        total_7: 831,
        total_19: 221,
        tax_7: 831 * 0.07,
        tax_19: 221 * 0.19,
        status: 'canceled',
        shipping_cost: 13,
        country_code: 'DE'
      expect(bill.customer_name).to eq "Hugo Harm"
      expect(bill.order_nr).to eq 2039132
      expect(bill.date).to eq "12.12.2012"
      expect(bill.total).to eq 192083
      expect(bill.total_0).to eq 13
      expect(bill.total_7).to eq 831
      expect(bill.total_19).to eq 221
      expect(bill.tax_7).to eq 831 * 0.07
      expect(bill.tax_19).to eq 221 * 0.19
      expect(bill.status).to eq 'canceled'
      expect(bill.shipping_cost).to eq 13
    end

    it 'does not allow unknown values' do
      expect { Magelex::LexwareBill.new bogus: :bagel }.to raise_error("Unknown values for bill: {:bogus=>:bagel}")
    end
  end

  describe '#swiss?' do
    it 'returns true for swiss orders' do
      expect(Magelex::LexwareBill.new.swiss?).to be false
      bill = Magelex::LexwareBill.new
      bill.country_code = 'CH'
      expect(bill.swiss?).to be true
      bill.country_code = 'DE'
      expect(bill.swiss?).to be false
    end
  end

  describe '#add_item' do
    before do
      @bill = Magelex::LexwareBill.new
    end

    it 'adds 0% tax items to total_0' do
      @bill.add_item(10, 0.0, 'magic')
      expect(@bill.total_0).to eq(10)
    end
    it 'adds 7% tax items to total_7' do
      @bill.add_item(10, 0.7, 'book')
      expect(@bill.total_7).to eq(10)
    end
    it 'adds 19% tax items to total_19' do
      @bill.add_item(10, 1.6, 'food')
      # 1.6?
      expect(@bill.total_19).to eq(10)
    end
    it 'adds tax part of 7% tax items to tax_7' do
      @bill.add_item(10, 0.7, 'book')
      expect(@bill.tax_7).to eq(0.7)
    end
    it 'adds tax part of 19% tax items to tax_19' do
      @bill.add_item(10, 1.6, 'food')
      expect(@bill.tax_19).to eq(1.6)
    end
  end

  describe '#customer_lastname' do
    it 'splits the name' do
      bill = Magelex::LexwareBill.new
      bill.customer_name = "John Doe"
      expect(bill.customer_lastname).to eq "Doe"
      bill.customer_name = "John The Loe"
      expect(bill.customer_lastname).to eq "Loe"
    end
  end

  describe '#in_eu?' do
    it 'correctly finds out whether Bill goes to EU.' do
      bill = Magelex::LexwareBill.new
      bill.country_code = 'BE'
      expect(bill.in_eu?).to be true
      bill.country_code = 'NC'
      expect(bill.in_eu?).to be false
    end
  end

  describe '#check' do
    it 'is true when total equals subtotals' do
      bill = Magelex::LexwareBill.new total: 900,
                                      total_0: 100,
                                      total_7: 200,
                                      total_19: 600
      expect(bill.check).to eq true
    end
    it 'is false when total does not equals subtotals' do
      bill = Magelex::LexwareBill.new total: 413,
                                      total_0: 100,
                                      total_7: 200,
                                      total_19: 600
      expect(bill.check).to eq false
    end
    it 'handles float corner cases' do
      bill = Magelex::LexwareBill.new total: 79.05,
        total_7: 9.95, total_19: 69.100004
      expect(bill.check).to eq true
    end
    it 'is false when total equals 0' do
      bill = Magelex::LexwareBill.new total: 0,
                                      total_0: 0,
                                      total_7: 0,
                                      total_19: 0
      expect(bill.check).to eq false
    end
    it 'is false when total < 0' do
      bill = Magelex::LexwareBill.new total: -10,
                                      total_0: 0,
                                      total_7: 0,
                                      total_19: 0
      expect(bill.check).to eq false
    end
    it 'is false when unknown tax item' do
      bill = Magelex::LexwareBill.new total: 0,
                                      total_0: 0,
                                      total_7: 0,
                                      total_19: 0
      bill.add_item -2, 10, ''
      expect(bill.check).to eq false
    end
    it 'includes incorrect_tax' do
      bill = Magelex::LexwareBill.new total: 5,
                                      total_0: 1,
                                      total_7: 0,
                                      total_19: 0,
                                      incorrect_tax: 4
      expect(bill.check).to eq true
    end
  end

  describe '#complete?' do
    it 'returns true if complete' do
      bill = Magelex::LexwareBill.new status: 'complete'
      expect(bill.complete?).to eq true
    end
    it 'returns false if not complete' do
      bill = Magelex::LexwareBill.new status: 'pending'
      expect(bill.complete?).to eq false
    end
  end

  describe '#process_shipping_costs' do
    it 'adds the shipping cost (*1.19) to total_19 and tax to tax_19' do
      bill = Magelex::LexwareBill.new shipping_cost: 12, total_19: 2
      expect(bill.total_19).to eq 2
      expect(bill.shipping_cost).to eq 12
      bill.process_shipping_costs
      expect(bill.total_19).to eq 16.28
      expect(bill.tax_19.round(2)).to eq 2.28
      expect(bill.shipping_cost).to eq 12
    end
    it 'keeps zero tax for shippings to switzerland' do
      bill = Magelex::LexwareBill.new shipping_cost: 12, total_0: 2, country_code: 'CH'
      expect(bill.total_19).to eq 0
      expect(bill.shipping_cost).to eq 12
      bill.process_shipping_costs
      expect(bill.total_0).to eq 14
      expect(bill.total_19).to eq 0
      expect(bill.tax_19).to eq 0
      expect(bill.shipping_cost).to eq 12
    end
  end

  describe '#swissify' do
    # total0 consumes total and resets others, if check passes
    # shipping costs should be consumed before
    # this has to be layed out in a graph or documented properly
    # (what happens when)
    it 'does nothing if bill not swiss' do
      bill = Magelex::LexwareBill.new shipping_cost: 12, total_19: 2
      expect(bill.total_19).to eq 2
      expect(bill.total_0).to eq 0
      bill.swissify
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
      bill.swissify
      bill.process_shipping_costs
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
      bill.swissify
      expect(bill.total_19).to eq 0
      expect(bill.total_7).to eq 0
      expect(bill.total_0).to eq (9 + 10 / 1.19)
      expect(bill.incorrect_tax).to eq (10 - 10 / 1.19)
      puts bill.inspect
      expect(bill.check_diff).to eq 0
      expect(bill.check).to eq true
    end
  end

  describe 'floor2' do
    it 'floors down with precision two' do
      expect(Magelex::LexwareBill.floor2 10.201231).to eq 10.20
      expect(Magelex::LexwareBill.floor2 11.299999).to eq 11.29
    end
  end
end
