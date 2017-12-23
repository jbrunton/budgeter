class Project < ApplicationRecord
  has_many :transactions
  has_many :statements

  def scan
    scan_dir = File.join(directory, 'statements')
    Dir.glob("#{scan_dir}/*.csv").map do |filename|
      statements.build(filename: File.basename(filename))
    end
  end

  def categories
    transactions.distinct.pluck(:category).compact
  end
end
