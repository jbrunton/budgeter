Rails.application.routes.draw do
  resources :transactions do
    collection do
      get 'sync', to: 'transactions#sync_confirm'
      post 'sync'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
