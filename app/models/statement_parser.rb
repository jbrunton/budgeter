class StatementParser
  def initialize(project)
    @project = project
  end

  def parse(string)
    csv_data = CSV.parse(string)
    header = csv_data.shift
    header_map = header.map{ |x| x.strip }.each_with_index.to_h

    csv_data.map do |row|
      @project.transactions.create({
        date: row[header_map['Date']],
        transaction_type: row[header_map['Type']],
        description: row[header_map['Description']],
        value: row[header_map['Value']],
        balance: row[header_map['Balance']]
      })
    end
  end
end