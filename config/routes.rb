Rails.application.routes.draw do

  resources :statements
  resources :projects do
    member do
      get 'export'

      get 'sync', to: 'sync#preview', as: 'preview_sync'
      post 'sync', to: 'sync#sync'

      get 'import', to: 'import#preview', as: 'preview_import'
      post 'import', to: 'import#import'

      get 'train', to: 'training#preview', as: 'preview_training'
      post 'train', to: 'training#train'

      get 'categories'
    end
    resources :transactions, shallow: true
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
