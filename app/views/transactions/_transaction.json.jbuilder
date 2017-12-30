json.extract! transaction, :id, :date, :description, :value, :balance, :category, :predicted_category, :verified, :verified_status, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
json.project_categories transaction.account.project.categories

