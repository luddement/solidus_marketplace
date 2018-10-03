Spree::Core::Engine.routes.draw do

  namespace :admin do
    resource :marketplace_settings
    resources :shipments
    resources :suppliers
    resources :reports, only: [:index] do
      collection do
        get   :earnings
        post  :earnings
        get :missing_suppliers
        post :missing_suppliers
      end
    end
  end

  namespace :api do
    resources :suppliers, only: :index
  end
end
