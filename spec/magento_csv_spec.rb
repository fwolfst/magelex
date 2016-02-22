require 'spec_helper'

describe Magelex::MagentoCSV do
  describe '#parse' do
    it 'parses empty string' do
      expect(Magelex::MagentoCSV.parse "").to eq([])
    end

    it 'parses orders exported via magento' do
      bills = Magelex::MagentoCSV.parse(File.read("spec/data/test_data.csv"))
      expect(bills.size).to eq(2)
    end

    it 'converts german format float fields' do
      bills = Magelex::MagentoCSV.parse(File.read("spec/data/test_data.csv"))
      expect(bills[0].total).to eq(79.05)
      expect(bills[0].shipping_cost).to eq(4.16)
    end

    it 'converts date field' do
      bills = Magelex::MagentoCSV.parse(File.read("spec/data/test_data.csv"))
      date = Date.civil(2015, 1, 1)
      expect(bills[0].date).to eq(date)
    end

    it 'handles swiss bill' do
      bills = Magelex::MagentoCSV.parse(File.read("spec/data/swiss.csv"))
      date = Date.civil(2015, 9, 8)
      expect(bills[0].date).to eq(date)
    end

    it 'adds up totals' do
      bills = Magelex::MagentoCSV.parse(File.read("spec/data/test_data.csv"))
      expect(bills[0].total_0).to eq(0)
      expect(bills[0].total_7).to eq(9.95)
      expect(bills[0].total_19).to eq(64.15)
      expect(bills[1].total_0).to eq(0)
      expect(bills[1].total_7).to eq(156.55)
      expect(bills[1].total_19).to eq(59.1)
      # TODO the total_0 case
    end
  end
  describe '#read' do
    it 'reads and parses file directly' do
      bills = Magelex::MagentoCSV.read "spec/data/test_data.csv"
      expect(bills.count).to eq 2
    end
  end

  describe "#init_bill" do
    it 'corrects rounding issues at shipping costs' do
      require 'ostruct'
      row = OpenStruct.new('Order Number' => '1',
                           'Order Shipping' => 12.6)
      bill = Magelex::MagentoCSV.init_bill row
      expect(bill.shipping_cost).to eq 15 / 1.19
    end
  end
end
