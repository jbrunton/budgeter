require 'digest'

class Transaction < ApplicationRecord
  belongs_to :project

  DATA_ATTRIBUTES = ['date', 'transaction_type', 'description', 'value', 'balance']

  def to_s
    "id: #{id}, #{date}, #{description}, #{category}"
  end

  def data_attributes
    attributes.slice(*DATA_ATTRIBUTES)
  end
end
