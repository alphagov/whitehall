ContentObjectStore::Engine.routes.draw do
  namespace :content_object_store, path: "/" do
    resources :health_check, path: "health-check", only: %i[index]
    root to: "health_check#index", via: :get
  end
end
