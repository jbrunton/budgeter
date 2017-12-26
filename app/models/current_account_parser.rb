require 'CSV'

class CurrentAccountParser
  def initialize(project)
    @project = project
  end

  def parse(file)
    csv_data = CSV.read(file)
    header = csv_data.shift
    header_map = header.map{ |x| x.strip }.each_with_index.to_h

    validate(csv_data, header_map)

    account_name = csv_data[0][header_map['Account Name']]
    account = @project.accounts.find_or_create_by(name: account_name)
    account.transactions.delete_all

    imported_transactions = csv_data.map do |row|
      account.transactions.build({
        date: row[header_map['Date']],
        transaction_type: row[header_map['Type']],
        description: row[header_map['Description']],
        value: row[header_map['Value']],
        balance: row[header_map['Balance']]
      })
    end

    imported_transactions.group_by{ |t| t.date }.each do |_, transactions|
      transactions.each_with_index { |t, index| t.date_index = index }
      transactions.each { |t| t.save }
    end

    imported_transactions
  end

private
  def validate(csv_data, header_map)
    if csv_data.map{ |row| row[header_map['Account Name']] }.uniq.length > 1
      raise "Please import transactions for one account at a time."
    end
  end
end