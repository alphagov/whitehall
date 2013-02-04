module Whitehall::DocumentFilter
  autoload :Mysql, 'whitehall/document_filter/mysql'
  autoload :FakeSearch, 'whitehall/document_filter/fake_search'
  autoload :ElasticSearch, 'whitehall/document_filter/elastic_search'
end
