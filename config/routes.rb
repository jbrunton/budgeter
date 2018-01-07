Rails.application.routes.draw do
  root 'projects#index'

  get 'projects/:id/statements', to: 'statements#index', as: 'project_statements'
  get 'projects/:id/statements/:date', to: 'statements#show', as: 'project_statement'
  get 'projects/:id/statements/:date/transactions', to: 'statements#transactions', as: 'statement_transactions'
  get 'projects/:id/statements/:date/summary', to: 'statements#summary', as: 'statement_summary'


  resources :projects do
    member do
      get 'backup', to: 'backup#index'
      get 'backup/download', to: 'backup#download'
      post 'backup/restore', to: 'backup#restore'

      get 'train', to: 'training#train'
      get 'preview', to: 'training#preview', as: 'training_preview'
      post 'classify', to: 'training#classify'

      get 'categories'

      get 'reports/spend', to: 'reports#spend'
      get 'reports/spend_data', to: 'reports#spend_data'
      get 'reports/balance', to: 'reports#balance'
      get 'reports/balance_data', to: 'reports#balance_data'
      get 'reports/income_outgoings', to: 'reports#income_outgoings'
      get 'reports/income_outgoings_data', to: 'reports#income_outgoings_data'
    end

    resources :accounts, shallow: true do
      resources :transactions, shallow: true do
        collection do
          get 'statement'
          get 'statement_summary'
        end
        member do
          post 'verify'
        end
      end
      member do
        get 'import_statement'
        post 'upload_statement'
      end
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
