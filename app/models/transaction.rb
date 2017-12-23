require 'digest'

class Transaction < ApplicationRecord
  belongs_to :project

  def to_s
    "id: #{id}, #{date}, #{description}, #{category}"
  end
  #
  # def self.local
  #   transactions = []
  #   Dir.glob("#{Rails.root}/transactions/*.csv").each do |file|
  #     puts "Found: #{file}"
  #     Parser.read(file).map do |attrs|
  #       transactions << Transaction.new(attrs)
  #     end
  #   end
  #   transactions
  # end
end
