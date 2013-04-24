module Whitehall::DocumentFilter
  autoload :Mysql, 'whitehall/document_filter/mysql'
  autoload :FakeSearch, 'whitehall/document_filter/fake_search'
  autoload :Rummager, 'whitehall/document_filter/rummager'
end
