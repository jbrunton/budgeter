class Statement < ApplicationRecord
  belongs_to :project

  def scan
    Parser.read(File.join(project.directory, 'statements', filename)).map do |attrs|
      project.transactions.build(attrs)
    end
  end
end
