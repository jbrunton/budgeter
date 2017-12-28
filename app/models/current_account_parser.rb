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
    if account_name.starts_with?("'")
      account_name.slice!(0)
    end

    account = @project.accounts.find_or_initialize_by(name: account_name)
    if account.new_record?
      account.account_type = 'current'
      account.save
    end

    candidate_transactions = csv_data.map do |row|
      account.transactions.build({
        date: row[header_map['Date']],
        transaction_type: row[header_map['Type']],
        description: row[header_map['Description']],
        value: row[header_map['Value']],
        balance: row[header_map['Balance']]
      })
    end

    duplicate_transactions = []
    imported_transactions = []
    candidate_transactions.group_by{ |t| t.date }.each do |date, transactions_on_date|
      existing_transactions_on_date = account.transactions.where(date: date)
      if existing_transactions_on_date.count > 0
        duplicate_transactions_for_date = []
        transactions_on_date.each do |t|
          e = existing_transactions_on_date.select{ |e| e.sha == t.sha }.first
          duplicate_transactions_for_date << e unless e.nil?
        end
        if duplicate_transactions_for_date.length > 0
          if duplicate_transactions_for_date.count != existing_transactions_on_date.count
            raise "Error: some duplicate transactions detected for #{date}"
          end
        end
        duplicate_transactions.concat(transactions_on_date)
      else
        transactions_on_date.each_with_index do |t, index|
          t.date_index = index
          t.save
        end
        imported_transactions.concat(transactions_on_date)
      end
    end

    {
      account: account,
      imported_transactions: imported_transactions,
      duplicate_transactions: duplicate_transactions
    }
  end

private
  def validate(csv_data, header_map)
    if csv_data.map{ |row| row[header_map['Account Name']] }.uniq.length > 1
      raise "Please import transactions for one account at a time."
    end
  end
end