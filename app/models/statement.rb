class Statement
  attr_reader :filename
  attr_reader :project

  def initialize(project, filename)
    @project = project
    @filename = filename
  end

  def scan_transactions
    Parser.read(File.join(project.directory, 'statements', filename)).each_with_index.map do |attrs, index|
      attrs[:statement_name] = filename
      attrs[:statement_index] = index
      project.transactions.build(attrs)
    end
  end
end
