Rails.application.routes.draw do
  resources :books, only: [] do
    resource :import, controller: "books/imports", only: %i[ create ]
  end
end
