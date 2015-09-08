if Rails.env.test?
  Whitehall.search_backend = Whitehall::DocumentFilter::Mysql
else
  Whitehall.search_backend = Whitehall::DocumentFilter::Rummager
end
