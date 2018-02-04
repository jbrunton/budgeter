require 'CSV'

class CsvStatementParser
  BALANCE_AT = /Balance as at/

  def initialize(account)
    @account = account
  end

  def parse(file)
    csv_data = CSV.read(file)
    header = csv_data.shift
    header_map = header.map{ |x| x.strip }.each_with_index.to_h

    validate_account(csv_data, header_map)

    candidate_transactions = build_candidate_transactions(csv_data, header_map)

    if @account.account_type == 'credit_card'
      last_transaction = candidate_transactions.pop
      if BALANCE_AT.match(last_transaction.description)
        current_balance = last_transaction.balance
        last_transaction.delete
      else
        raise "Error: expected last transaction to be the account balance."
      end

      update_balances(candidate_transactions, current_balance)
    else
      validate_balances(candidate_transactions)
    end

    TransactionImporter.new(@account).import(candidate_transactions)
  end

private
  def validate_account(csv_data, header_map)
    if csv_data.map{ |row| row[header_map['Account Name']] }.uniq.length > 1
      raise "Please import transactions for one account at a time."
    end
  end

  def validate_balances(candidate_transactions)
    candidate_transactions.each do |t|
      if t.balance.nil?
        raise "Error: expected balance for all transactions."
      end
    end
  end

  def build_candidate_transactions(csv_data, header_map)
    csv_data.map do |row|
      @account.transactions.build({
        date: row[header_map['Date']],
        description: row[header_map['Description']],
        value: row[header_map['Value']],
        balance: row[header_map['Balance']]
      })
    end
  end

  def update_balances(candidate_transactions, current_balance)
    candidate_transactions.reverse.each do |t|
      t.balance = current_balance
      current_balance -= t.value
    end
  end
end