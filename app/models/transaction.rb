require 'digest'

class Transaction < ApplicationRecord
  belongs_to :project

  default_scope { order(:date, :date_index) }

  DATA_ATTRIBUTES = [
    'account_name',
    'date',
    'date_index',
    'transaction_type',
    'description',
    'value',
    'balance'
  ]

  def to_s
    "id: #{id}, #{date}, #{description}, #{category}"
  end

  def data_attributes
    attributes.slice(*DATA_ATTRIBUTES)
  end

  def assess_prediction
    if predicted_category.nil?
      :no_prediction
    elsif category == predicted_category
      :correct
    else
      :incorrect
    end
  end
end
