Rails.application.routes.draw do
  resources :books, only: [] do
    resource :import, only: %i[ create ], module: :books
  end
  get "/:id/:slug", to: "books#show", constraints: { id: /\d+/ }, as: :slugged_book
  direct :book_slug do |book, options|
    route_for :slugged_book, book, book.slug, options
  end
end
