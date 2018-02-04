class TransactionImporter
  def initialize(account)
    @account = account
  end

  def import(transactions)
    duplicate_transactions = []
    imported_transactions = []
    transactions.group_by{ |t| t.date }.each do |date, transactions_on_date|
      existing_transactions_on_date = @account.transactions.where(date: date)
      if existing_transactions_on_date.count > 0
        duplicate_transactions.concat duplicate_transactions_on_date(
          date, existing_transactions_on_date, transactions_on_date)
      else
        save_transactions(transactions_on_date)
        imported_transactions.concat(transactions_on_date)
      end
    end

    {
      imported_transactions: imported_transactions,
      duplicate_transactions: duplicate_transactions
    }
  end

private
  def duplicate_transactions_on_date(date, existing_transactions, candidate_transactions)
    duplicates = []
    candidate_transactions.each do |t|
      duplicate = find_duplicate(t, existing_transactions)
      duplicates << duplicate unless duplicate.nil?
    end
    validate_duplicates(duplicates, existing_transactions, date)
    duplicates
  end

  def find_duplicate(transaction, existing_transactions)
    existing_transactions.select{ |e| e.sha == transaction.sha }.first
  end

  def validate_duplicates(duplicates, existing_transactions, date)
    if duplicates.length > 0
      if duplicates.count != existing_transactions.count
        raise "Error: some duplicate transactions detected for #{date}"
      end
    end
  end

  def save_transactions(transactions)
    transactions.each_with_index do |t, index|
      t.date_index = index
      t.save
    end
  end
end