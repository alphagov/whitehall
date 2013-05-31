if Rails.env.production? || ENV["RUMMAGER_HOST"]
  Whitehall.search_backend = Whitehall::DocumentFilter::Rummager
else
  Whitehall.search_backend = Whitehall::DocumentFilter::Mysql
end
