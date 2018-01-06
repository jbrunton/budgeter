json.extract! transaction, :id, :date, :description, :value, :balance, :assigned_category, :predicted_category, :categorized_status, :assess_prediction, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
json.project_categories transaction.account.project.categories

