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
    it 'adds up totals' do
      bills = Magelex::MagentoCSV.parse(File.read("spec/data/test_data.csv"))
      expect(false).to eq(true)
    end
  end
end
