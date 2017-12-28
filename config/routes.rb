Rails.application.routes.draw do
  root 'projects#index'

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
      get 'reports/balance', to: 'reports#balance'
    end

    resources :accounts, shallow: true do
      resources :transactions, shallow: true
      member do
        get 'import_statement'
        post 'upload_statement'
      end
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
