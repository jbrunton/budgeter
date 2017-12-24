require 'digest'

class Transaction < ApplicationRecord
  belongs_to :project

  DATA_ATTRIBUTES = [
    'date',
    'transaction_type',
    'description',
    'value',
    'balance',
    'statement_name',
    'statement_index',
    'store_name',
    'store_index'
  ]

  def to_s
    "id: #{id}, #{date}, #{description}, #{category}"
  end

  def data_attributes
    attributes.slice(*DATA_ATTRIBUTES)
  end
end
