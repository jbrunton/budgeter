require 'digest'

class Transaction < ApplicationRecord
  belongs_to :project

  default_scope { order(:date, :statement_name, :statement_index) }

  DATA_ATTRIBUTES = [
    'date',
    'transaction_type',
    'description',
    'value',
    'balance',
    'statement_name',
    'statement_index'
  ]

  def to_s
    "id: #{id}, #{date}, #{description}, #{category}"
  end

  def data_attributes
    attributes.slice(*DATA_ATTRIBUTES)
  end
end
