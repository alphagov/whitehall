scope "/get-involved" do
  root to: "get_involved#index", as: :get_involved, via: :get
  resources :take_part_pages, except: [:show] do
    post :reorder, on: :collection
    get :confirm_destroy, on: :member
    get :update_order, on: :collection
  end
end
