Rails.application.routes.draw do

  resources :statements
  resources :projects do
    member do
      get 'backup', to: 'backup#index'
      get 'backup/download', to: 'backup#download'
      post 'backup/import', to: 'backup#import'

      get 'train', to: 'training#preview', as: 'preview_training'
      post 'train', to: 'training#train'

      get 'categories'
    end
    resources :transactions, shallow: true do
      collection do
        get 'import'
        post 'upload'
      end
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
