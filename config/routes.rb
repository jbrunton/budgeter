Rails.application.routes.draw do

  resources :statements
  resources :projects do
    member do
      get 'sync', to: 'sync#preview', as: 'preview_sync'
      post 'sync', to: 'sync#sync'
      get 'categories'
    end
    resources :transactions, shallow: true
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
