Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  # Authenticated routes
  get  "dashboard",    to: "dashboard#index",         as: :dashboard
  resources :booking_links, only: [:index, :create]

  # Stripe Connect hosted onboarding
  get  "stripe/connect", to: "stripe_connect#connect",          as: :stripe_connect
  get  "stripe/return",  to: "stripe_connect#onboarding_return", as: :stripe_return

  get  "success", to: "bookings#success", as: :booking_success

  # Refund
  post "payments/:id/refund", to: "payments#refund", as: :refund_payment

  # Stripe webhooks
  post "webhooks/stripe", to: "webhooks#stripe"

  get "terms",   to: "pages#terms",   as: :terms
  get "privacy",  to: "pages#privacy",  as: :privacy

  root to: "home#index"

  # Public booking page — must stay last so it doesn't shadow routes above
  get  ":business_slug/:slug",          to: "bookings#show",    as: :booking
  post ":business_slug/:slug/checkout", to: "bookings#checkout", as: :booking_checkout
end
