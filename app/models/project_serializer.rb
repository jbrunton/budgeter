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
    @project.ignore_words = content['ignore_words']
    @project.save

    @project.accounts.delete_all
    content['accounts'].each do |account_attrs|
      account = @project.accounts.create(account_attrs.slice('name', 'account_type'))
      account_attrs['transactions'].each do |transaction_attrs|
        account.transactions.create(transaction_attrs)
      end
    end
  end

private
  def marshal_project
    {
      'name' => @project.name,
      'ignore_words' => @project.ignore_words,
      'accounts' => @project.accounts.map { |account| marshal_account(account) }
    }
  end

  def marshal_account(account)
    {
      'name' => account.name,
      'account_type' => account.account_type,
      'transactions' => account.transactions.map { |transaction| marshal_transaction(transaction) }
    }
  end

  def marshal_transaction(transaction)
    attrs = transaction.data_attributes
    attrs['value'] = currency(attrs['value'])
    attrs['balance'] = currency(attrs['balance'])
    attrs['category'] = transaction.category
    attrs['predicted_category'] = transaction.predicted_category
    attrs
  end
end