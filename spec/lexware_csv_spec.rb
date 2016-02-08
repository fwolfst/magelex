require 'spec_helper'

describe Magelex::LexwareCSV do
  describe '#render' do
    it 'renders' do
      bill = Magelex::LexwareBill.new order_nr: 10229,
        customer_name: 'Henning Schull', date: Date.civil(2015,8,19),
        total: 123.81, total_7: 700, total_19: 1900, total_0: 10
      expected_csv = "19.08.2015,10229,Henning Schull,123.81,11800,0\n"\
        "19.08.2015,10229,Henning Schull,10.0,0,8120\n"\
        "19.08.2015,10229,Henning Schull,700.0,0,8300\n"\
        "19.08.2015,10229,Henning Schull,1900.0,0,8400\n"\
                     ""
      expect(Magelex::LexwareCSV.render [bill]).to eq expected_csv
    end
  end

  describe '#to_rows' do
    it 'handles split booking' do
      bill = Magelex::LexwareBill.new order_nr: 10229,
        customer_name: 'Henning Schull', date: Date.civil(2015,8,19),
        total: 123.81, total_7: 700, total_19: 1900, total_0: 10
      expected_rows = [["19.08.2015",10229,"Henning Schull",123.81,11800,0],
                       ["19.08.2015",10229,"Henning Schull",10.0,0,"8120"],
                       ["19.08.2015",10229,"Henning Schull",700.0,0,"8300"],
                       ["19.08.2015",10229,"Henning Schull",1900.0,0,"8400"]]
      expect(Magelex::LexwareCSV.to_rows bill).to eq expected_rows
    end
    it 'handles non-split booking' do
      bill = Magelex::LexwareBill.new order_nr: 10229,
        customer_name: 'Henning Schull', date: Date.civil(2015,8,19),
        total: 123.81, total_7: 123.81
      expected_rows = [["19.08.2015", 10229,
                        "Henning Schull", 123.81, 11800, "8300"]]
      expect(Magelex::LexwareCSV.to_rows bill).to eq expected_rows
    end
  end
end
