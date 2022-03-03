Whitehall::Application.config.to_prepare do
  Whitehall.search_backend = Whitehall::DocumentFilter::SearchRummager
end
