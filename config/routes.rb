Rails.application.routes.draw do

  resources :statements
  resources :projects do
    member do
      get 'sync', to: 'sync#preview'
      post 'sync', to: 'sync#sync'
    end
  end
  resources :transactions do
    collection do
      get 'sync', to: 'transactions#sync_confirm'
      post 'sync'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
