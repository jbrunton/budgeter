class Project < ApplicationRecord
  has_many :transactions
  has_many :statements

  def scan_statement_transactions
    scan_dir = File.join(directory, 'statements')
    statements = Dir.glob("#{scan_dir}/*.csv").map do |filename|
      Statement.new(self, File.basename(filename))
    end
    statements.map{ |statement| statement.scan_transactions }.flatten
  end

  def scan_stored_transactions
    stored_transactions = []
    Dir.glob(File.join(directory, 'transactions/*.yaml')).each do |filename|
      content = YAML.load_file(filename)
      if content['transactions']
        content['transactions'].each do |attrs|
          stored_transactions << transactions.build(attrs)
        end
      end
    end
    stored_transactions
  end

  def categories
    transactions.distinct.pluck(:category).compact
  end
end
