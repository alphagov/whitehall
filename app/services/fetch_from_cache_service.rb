class FetchFromCacheService
  attr_reader :type, :slug

  def initialize(type, slug)
    @type = type
    @slug = slug
  end

  def fetch
    Rails.cache.fetch("#{type}-#{slug}", namespace: "results", expires_in: 30.minutes, race_condition_ttl: 1.second) do
      case type
      when :organisation
        Organisation.includes(:translations).find_by(slug: slug)
      when :topic
        Classification.find_by(slug: slug)
      when :document_collection
        # Don't fall over if index refers a document which has had it's slug changed.
        Document.find_by(slug: slug).try(:published_edition)
      when :operational_field
        OperationalField.find_by(slug: slug)
      else
        raise "Can't fetch '#{type}' -- unknown type"
      end
    end
  end
end
