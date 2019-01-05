class Account < ApplicationRecord
  belongs_to :project
  has_many :transactions

  TYPES = ['current', 'credit_card']

  scope :current, -> { where(account_type: 'current') }
  scope :credit_card, -> { where(account_type: 'credit_card') }

  def categories
    transactions.distinct.pluck(:assigned_category).compact
  end

  def balance_on(date)
    last_transaction = transactions.where('date <= ?', date).last
    last_transaction.try(:balance)
  end

  def income_between(from_date, to_date)
    if account_type == 'current'
      transactions.where('? <= date AND date < ? AND value > 0', from_date, to_date).sum(:value)
    else
      transactions.where('? <= date AND date < ? AND value < 0', from_date, to_date).sum(:value)
    end
  end

  def verification_state
    VerificationState.new(transactions).compute_state
  end
end
