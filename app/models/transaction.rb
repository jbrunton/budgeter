require 'digest'

class Transaction < ApplicationRecord
  belongs_to :account

  before_save :clean_category

  scope :by_date, ->{ order(:date, :date_index) }
  scope :by_amount, -> { order('abs(value) desc') }
  scope :between, ->(start_date, end_date) { where(date: start_date..end_date.yesterday) }
  scope :within_month, ->(beginning_of_month) { between(beginning_of_month, beginning_of_month.next_month) }

  DATA_ATTRIBUTES = [
    'date',
    'date_index',
    'description',
    'value',
    'balance'
  ]

  def normalized_value
    account.account_type == 'credit_card' ? -value : value
  end

  def to_s
    "id: #{id}, #{date}, #{description}, #{category}"
  end

  def data_attributes
    attributes.slice(*DATA_ATTRIBUTES)
  end

  def assess_prediction
    puts "verifying 8" if id == 8
    puts "         verifiable?: #{verifiable?}" if id == 8
    puts "   verified_category: #{verified_category}" if id == 8
    puts "  predicted_category: #{predicted_category}" if id == 8
    if !verifiable?
      puts "  :no_prediction" if id == 8
      :no_prediction
    elsif verified_category == predicted_category
      puts "  :correct" if id == 8
      :correct
    else
      puts "  :incorrect" if id == 8
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

  def verified_status
    if !category.blank? || verified
      :verified
    else
      :unverified
    end
  end

  def verifiable?
    verified || !category.blank?
  end

  def verified_category
    if !category.blank?
      category
    else
      # we may be doing a preview, in which case the in-memory prediction
      # doesn't have to correlate to the actually verified category
      Transaction.find(id).predicted_category
    end
  end

private
  def clean_category
    if category.blank?
      self.category = nil
    end
  end
end
