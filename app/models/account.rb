class Account < ApplicationRecord
  belongs_to :project
  has_many :transactions

  scope :current, -> { where(account_type: 'current') }
  scope :credit_card, -> { where(account_type: 'credit_card') }

  def categories
    transactions.distinct.pluck(:category).compact
  end

  def balance_on(date)
    last_transaction = transactions.where('date <= ?', date).last
    last_transaction.try(:balance)
  end
end
