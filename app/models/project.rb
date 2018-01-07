class Project < ApplicationRecord
  has_many :accounts
  has_many :transactions, through: :accounts

  def statements
    Statement.for(self)
  end

  def scan_statement_transactions
    scan_dir = File.join(directory, 'statements')
    statements = Dir.glob("#{scan_dir}/*.csv").map do |filename|
      Statement.new(self, File.basename(filename))
    end
    statements.map{ |statement| statement.scan_transactions }.flatten
  end

  def scan_stored_transactions
    stored_transactions = []
    Dir.glob(File.join(directory, 'transactions/*.yaml')).each do |filename|
      content = YAML.load_file(filename)
      if content['transactions']
        content['transactions'].each do |attrs|
          stored_transactions << transactions.build(attrs)
        end
      end
    end
    stored_transactions
  end

  def categories
    accounts.map{ |account| account.categories }.flatten.uniq
  end

  def verification_state
    VerificationState.new(transactions).compute_state
  end

  def sum_category(category, month_start, account_ids)
    transactions
      .within_month(month_start)
      .joins(:account)
      .where('coalesce(assigned_category, predicted_category) = ?', category)
      .where('account_id in (?)', account_ids)
      .sum("case accounts.account_type when 'credit_card' then -value else value end")
  end
end
