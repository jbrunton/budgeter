require 'CSV'

class StatementParser
  def initialize(project)
    @project = project
  end

  def parse(string)
    csv_data = CSV.parse(string)
    header = csv_data.shift
    header_map = header.map{ |x| x.strip }.each_with_index.to_h

    @project.transactions.delete_all

    candidate_transactions = csv_data.map do |row|
      @project.transactions.build({
        account_name: row[header_map['Account Name']],
        date: row[header_map['Date']],
        transaction_type: row[header_map['Type']],
        description: row[header_map['Description']],
        value: row[header_map['Value']],
        balance: row[header_map['Balance']]
      })
    end

    candidate_transactions.group_by{ |t| t.date }.each do |date, transactions|
      transactions.each_with_index { |t, index| t.date_index = index }
      transactions.each { |t| t.save }
    end

    candidate_transactions
  end
end