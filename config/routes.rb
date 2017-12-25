Rails.application.routes.draw do

  resources :statements
  resources :projects do
    member do
      get 'export'

      get 'import'
      post 'upload'

      get 'train', to: 'training#preview', as: 'preview_training'
      post 'train', to: 'training#train'

      get 'categories'
    end
    resources :transactions, shallow: true
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
