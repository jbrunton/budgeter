Rails.application.routes.draw do

  resources :statements
  resources :projects do
    member do
      get 'sync', to: 'sync#preview'
      post 'sync', to: 'sync#sync'
    end
    resources :transactions, shallow: true
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
