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

  def category
    assigned_category || verified_category
  end

  def assess_prediction
    if !categorized?
      :no_prediction
    elsif !verified_category.nil? && verified_category == predicted_category
      :correct
    elsif !assigned_category.nil? && assigned_category == predicted_category
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

  def verify(verified)
    if verified
      self.verified_category = self.predicted_category
    else
      self.verified_category = nil
    end
    self.save
  end

  def verified?
    !self.verified_category.nil?
  end

  def categorized?
    verified? || !assigned_category.nil?
  end

  def categorized_status
    if categorized?
      :categorized
    else
      :uncategorized
    end
  end

private
  def clean_category
    if assigned_category.blank?
      self.assigned_category = nil
    end
  end
end
