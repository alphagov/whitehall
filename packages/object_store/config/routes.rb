ObjectStore::Engine.routes.draw do
  namespace :object_store, path: "/" do
    root to: "objects#index", via: :get

    resources :objects
  end
end
