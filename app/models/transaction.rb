require 'digest'

class Transaction < ApplicationRecord
  belongs_to :account

  scope :by_date, ->{ order(:date, :date_index) }
  scope :by_amount, -> { order('abs(value) desc') }
  scope :between, ->(start_date, end_date) { where(date: start_date..end_date.yesterday) }
  scope :within_month, ->(beginning_of_month) { between(beginning_of_month, beginning_of_month.next_month) }

  DATA_ATTRIBUTES = [
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

  def sha
    @sha ||= begin
      md5 = Digest::MD5.new
      md5 << date.strftime('%Y-%m-%d')
      md5 << description
      md5 << value.to_s
    end
  end
end
