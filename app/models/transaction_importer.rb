class TransactionImporter
  def initialize(account)
    @account = account
  end

  def import(candidate_transactions)
    duplicate_transactions = []
    imported_transactions = []
    candidate_transactions.group_by{ |t| t.date }.each do |date, transactions_on_date|
      existing_transactions_on_date = @account.transactions.where(date: date)
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
      imported_transactions: imported_transactions,
      duplicate_transactions: duplicate_transactions
    }
  end
end