# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'

  namespace :admin do
    resources :announcements
    root to: 'announcements#index'

    resources :members, param: :username
    root to: 'members#index'

    resources :categories
    root to: 'categories#index'

    resources :posts, param: :slug
    root to: 'posts#index'
  end

  devise_for :members, skip: [:registrations], controllers: {
    invitations: 'invitations'
  }

  authenticate :member do
    resources :members, param: :username
    root to: 'home#index'

    resources :posts, param: :slug, path: :conversations do
      resources :comments
      root to: 'posts#index'
    end

    resources :announcements
    root to: 'announcements#index'

    resources :categories
    root to: 'categories#index'
  end
end
