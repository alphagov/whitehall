module Whitehall
  class SearchIndex
    def self.for(type)
      method = {
        government: :government_search_index_path,
        detailed_guides: :detailed_guidance_search_index_path
      }.fetch(type)
      path = Whitehall.send(method)
      indexer_class.new(rummager_host, path, logger: Rails.logger)
    end

    def self.indexer_class
      if ENV.has_key?('RUMMAGER_HOST') || Rails.env.production?
        Rummageable::Index
      else
        Rummageable::FakeIndex
      end
    end

    def self.rummager_host
      ENV.fetch('RUMMAGER_HOST', Plek.current.find('search'))
    end
  end
end
