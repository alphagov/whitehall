Whitehall.search_backend = if Rails.env.test?
                             Whitehall::DocumentFilter::Mysql
                           else
                             Whitehall::DocumentFilter::AdvancedSearchRummager
                           end
