json.extract! transaction, :id, :date, :type, :description, :value, :balance, :category, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
