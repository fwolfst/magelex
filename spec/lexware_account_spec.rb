require 'spec_helper'

describe Magelex::AccountNumber do
  describe "#for_customer" do
    before do
      @bill = Magelex::LexwareBill.new
    end
    it "starts with 10000 for 'A'" do
      @bill.customer_name = "Adam Aisle"
      expect(Magelex::AccountNumber.for_customer @bill).to eq(10000)
    end
    it "with an i its 8" do
      @bill.customer_name = "Ilse Immer IhmRau"
      expect(Magelex::AccountNumber.for_customer @bill).to eq(10800)
    end
    it "handles special y case" do
      @bill.customer_name = "Yuse Yimmer"
      expect(Magelex::AccountNumber.for_customer @bill).to eq(12300)
    end
    it "handles umlauts case" do
      @bill.customer_name = "Öuse Öxume"
      bill2 = Magelex::LexwareBill.new
      bill2.customer_name = "Ouse Oxume"
      expect(Magelex::AccountNumber.for_customer @bill).to eq(Magelex::AccountNumber.for_customer(bill2))
    end
    it "handles special z case" do
      @bill.customer_name = "Zuse Zimmer"
      expect(Magelex::AccountNumber.for_customer @bill).to eq(12300)
    end
  end

  describe '#for_7' do
    before do
      @bill = Magelex::LexwareBill.new
    end
    it 'is 8300 for german customer' do
      @bill.country_code = 'DE'
      expect(Magelex::AccountNumber.for_7(@bill)).to eq '8300'
    end
    it 'is 8310 for non-german EU customer' do
      @bill.country_code = 'BE'
      expect(Magelex::AccountNumber.for_7(@bill)).to eq '8310'
    end
  end

  describe '#for_19' do
    before do
      @bill = Magelex::LexwareBill.new
    end
    it 'is 8400 for german customer' do
      @bill.country_code = 'DE'
      expect(Magelex::AccountNumber.for_19(@bill)).to eq '8400'
    end
    it 'is 8315 for non-german EU customer' do
      @bill.country_code = 'BE'
      expect(Magelex::AccountNumber.for_19(@bill)).to eq '8315'
    end
  end
end
