require 'digest'

class Transaction < ApplicationRecord
  before_save :set_hash_code

  validates_inclusion_of :status, :in => %w( pending training classified unclassified )

  def compute_hash_code
    sha1 = Digest::SHA1.new
    [date, transaction_type, description, value, balance, category].each do |val|
      sha1.update val.to_s
    end
    sha1.hexdigest
  end

  def to_s
    "id: #{id}, #{date}, #{description}, #{category}"
  end

  def self.local
    transactions = []
    Dir.glob("#{Rails.root}/transactions/*.csv").each do |file|
      puts "Found: #{file}"
      Parser.read(file).map do |attrs|
        transactions << Transaction.new(attrs)
      end
    end
    transactions
  end

  def self.pending
    local.select{ |t| !t.duplicate? }
  end

  def duplicate?
    Transaction.where(hash_code: compute_hash_code).exists?
  end

private
  def set_hash_code
    puts "setting hash code"
    if status == 'pending' then
      puts "status == pending, hash_code = nil"
      self.hash_code = nil
    else
      puts "status != pending, hash_code = compute_hash_code"
      self.hash_code = compute_hash_code
    end
  end
end
