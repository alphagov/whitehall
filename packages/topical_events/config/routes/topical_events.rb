resources :topical_events, path: "topical-events" do
  resource :topical_event_about_pages, path: "about"
  resources :topical_event_featurings, path: "featurings" do
    get :reorder, on: :collection
    put :order, on: :collection
    get :confirm_destroy, on: :member
  end
  resources :topical_event_organisations, path: "organisations" do
    get :reorder, on: :collection
    put :order, on: :collection
    get :toggle_lead, on: :member
  end
  resources :offsite_links do
    get :confirm_destroy, on: :member
  end
  get :confirm_destroy, on: :member
end
