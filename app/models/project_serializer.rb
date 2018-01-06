class ProjectSerializer
  include FormatHelper

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
    @project.seed = content['seed']
    @project.save

    @project.accounts.delete_all
    content['accounts'].each do |account_attrs|
      account = @project.accounts.create(account_attrs.slice('name', 'account_type'))
      account_attrs['transactions'].each do |transaction_attrs|
        transaction_attrs['value'].tr!(',', '')
        transaction_attrs['balance'].tr!(',', '')
        transaction_attrs['assigned_category'] = transaction_attrs['category']
        transaction_attrs.delete('category')
        transaction_attrs.delete('verified')
        account.transactions.create(transaction_attrs)
      end
    end
  end

private
  def marshal_project
    {
      'name' => @project.name,
      'ignore_words' => @project.ignore_words,
      'seed' => @project.seed,
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
    attrs['assigned_category'] = transaction.assigned_category
    attrs['predicted_category'] = transaction.predicted_category
    attrs['verified_category'] = transaction.verified_category
    attrs
  end
end