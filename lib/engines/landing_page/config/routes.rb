LandingPage::Engine.routes.draw do
  namespace :landing_page, path: "/" do
    resources :landing_pages
  end
end
