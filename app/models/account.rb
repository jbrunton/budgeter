class Account < ApplicationRecord
  belongs_to :project
  has_many :transactions

  def categories
    transactions.distinct.pluck(:category).compact
  end
end
