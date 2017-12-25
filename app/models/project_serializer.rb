class ProjectSerializer
  include CurrencyHelper

  def initialize(project)
    @project = project
  end

  def serialize
    marshal_project.to_yaml
  end

  def deserialize(string)
    content = YAML.load(string)
    @project.name = content['name']
    @project.transactions.delete_all
    content['transactions'].each do |attrs|
      @project.transactions.create(attrs)
    end
  end

private
  def marshal_project
    {
      'name' => @project.name,
      'ignore_words' => @project.ignore_words,
      'transactions' => @project.transactions.map { |transaction| marshal_transaction(transaction) }
    }
  end

  def marshal_transaction(transaction)
    attrs = transaction.data_attributes
    attrs['value'] = currency(attrs['value'])
    attrs['balance'] = currency(attrs['balance'])
    attrs['category'] = transaction.category
    attrs
  end
end