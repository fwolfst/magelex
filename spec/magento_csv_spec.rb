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
      expect(bills.count).to eq(2)
      expect(bills.count{|b| b.swiss?}).to eq(2)
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
    it 'corrects rounding issues at shipping costs (15€)' do
      require 'ostruct'
      row = OpenStruct.new('Order Number' => '1',
                           'Order Shipping' => 12.6)
      bill = Magelex::MagentoCSV.init_bill row
      expect(bill.shipping_cost).to eq 15 / 1.19
    end
    it 'corrects rounding issues at shipping costs (4.95€)' do
      require 'ostruct'
      row = OpenStruct.new('Order Number' => '1',
                           'Order Shipping' => 4.15)
      bill = Magelex::MagentoCSV.init_bill row
      expect(bill.shipping_cost).to eq 4.95 / 1.19
    end
  end

  describe "it corrects rounding issues in shipping cost calculation" do
    it 'does' do
      bills = Magelex::MagentoCSV.read "spec/data/escaped.csv"
      bills.each do |b| 
        puts b.inspect
      end
      expect(bills.count).to eq 2
      #100017647
      #name: "Frau Aust, Beate"
    end
  end

  pending "it handles rounding issues" do
      #100017647
      #name: "Frau Aust, Beate" ?
    #
#    Also z. B.  im Datensatz _182 die Bestellnummer 100018404 (Datensatz siehe Anhang)
#
#    Die Buchung hätte lauten sollen 
#    45,90 11300 - 8315 und
#    367,05 - 11300 - 8310
#
#    im log steht
#
#    INFO - 2016-02-16 17:11:02 +0100 - Skip order 100018404
#    INFO - 2016-02-16 17:11:02 +0100 - (totals do not match 412.95 != (0: 0 + 7: 367.04999999999995 + 19: 45.89 = 412.93999999999994) 
  end
end
