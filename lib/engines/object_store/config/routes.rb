Whitehall::Application.routes.draw do
  namespace :object_store, path: "/" do
    root to: "content_blocks#index", via: :get

    resources :content_blocks
  end
end
