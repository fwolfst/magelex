require 'spec_helper'

describe Magelex::LexwareBill do
  it 'can be initialized' do
    expect(Magelex::LexwareBill.new).not_to be nil
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
      expect(@bill.total_19).to eq(10)
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
end
