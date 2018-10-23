module Whitehall::DocumentFilter
  autoload :Mysql, 'whitehall/document_filter/mysql'
  autoload :FakeSearch, 'whitehall/document_filter/fake_search'
  autoload :AdvancedSearchRummager, 'whitehall/document_filter/advanced_search_rummager'
  autoload :SearchRummager, 'whitehall/document_filter/search_rummager'
end
