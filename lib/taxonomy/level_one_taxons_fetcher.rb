class Taxonomy::LevelOneTaxonsFetcher
  def self.fetch
    root_taxon = Rails.cache.fetch('taxonomy.root_taxon', expires_in: 15.minutes) do
      Whitehall.content_store.content_item('/')
    end
    level_one_taxon_hashes = root_taxon.dig('links', 'level_one_taxons') || []
    taxons = level_one_taxon_hashes.map do |level_one_taxon_hash|
      Taxonomy::Taxon.from_taxon_hash(level_one_taxon_hash)
    end
    live_taxons = taxons.select { |t| t.phase == 'live' }
    live_taxons.sort_by(&:name)
  rescue GdsApi::ContentStore::ItemNotFound
    {}
  end
end
