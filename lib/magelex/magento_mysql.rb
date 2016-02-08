require 'mysql2'

module Magelex
  module MagentoMYSQL
    def self.update_dates mysqlconf, bills
      @client = Mysql2::Client.new(host: mysqlconf["host"],
                                   port: mysqlconf["port"],
                                   database: mysqlconf["database"],
                                   username: mysqlconf["username"],
                                   password: mysqlconf["password"])

      in_statement = bills.map{|b| "'#{b.order_nr}'"}.join(',')
      query = "SELECT increment_id, created_at, updated_at, "\
        "invoice_status_id  FROM sales_flat_invoice "\
        "WHERE increment_id IN (#{in_statement});"

      # Build up index TODO rubyfy
      bill_idx = {}
      bills.each {|b| bill_idx[b.order_nr.to_s] = b}
      results = @client.query(query)

      results.each do |row|
        bill_idx[row['increment_id']].date = row['created_at']
      end
    end
  end
end
