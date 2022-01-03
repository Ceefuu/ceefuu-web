Rails.application.routes.draw do

  get 'message/create'
  root 'pages#home'

  get 'pages/terms', to: 'pages#terms'
  get 'pages/privacy', to: 'pages#privacy'
  get 'pages/cookies', to: 'pages#cookies'

  get '/dashboard', to: 'users#dashboard'
  get '/users/:id', to: 'users#show', as: 'users'
  get '/selling_orders', to: 'orders#selling_orders'
  get '/buying_orders', to: 'orders#buying_orders'
  get '/orders/:id', to: 'orders#show', as: "order_detail"
  get '/search', to: 'pages#search'
  get '/calendar', to: 'pages#calendar'
  get '/plans', to: 'pages#plans'
  get '/settings/payment', to: 'users#payment', as: 'settings_payment'
  get '/settings/payout', to: 'users#payout', as: 'settings_payout'
  get '/contents/:id/checkout/:pricing_type', to: 'contents#checkout', as: 'checkout'
  get '/earnings', to: 'users#earnings', as: 'earnings'
  get '/conversations', to: 'conversations#list', as: "conversations"
  get '/conversations/:id', to: 'conversations#show', as: "conversation_detail"

  post '/users/edit', to: 'users#update'
  post '/reviews', to: 'reviews#create'
  post '/settings/payment', to: 'users#update_payment', as: "update_payment"
  post '/settings/payout', to: 'users#update_payout', as: "update_payout"
  post '/users/withdraw', to: 'users#withdraw', as: 'withdraw'
  post 'messages', to: 'messages#create'
  post '/comments', to: 'comments#create'
  post '/subscribe', to: 'subscriptions#subscribe'
  post '/webhook', to: 'subscriptions#webhook'

  put '/orders/:id/complete', to: 'orders#complete', as: 'complete_order'
  put '/offers/:id/accept', to: 'offers#accept', as: 'accept_offer'
  put '/offers/:id/reject', to: 'offers#reject', as: 'reject_offer'

  delete '/users/remove_subscription', to: 'users#remove_subscription', as: 'remove_subscription'

  mount ActionCable.server => '/cable'

  resources :contents do
    member do
      delete :delete_photo
      post :upload_photo
    end
    resources :orders, only: [:create]
  end

  resources :pages do 
    collection do
      get :terms, :privacy, :cookies
    end
  end

  resources :requests

  devise_for :users, 
              path: '', 
              path_names: {sign_up: 'register', sign_in: 'login', edit: 'profile', sign_out: 'logout'},
              controllers: {omniauth_callbacks: 'omniauth_callbacks', registrations: 'registrations'}

  resources :users, only: [:show] do
    member do
      post '/verify_phone' => 'users#verify_phone'
      patch '/update_phone' => 'users#update_phone'
      get :following, :followers
    end
  end

  resources :relationships, only: [:create, :destroy]
end
