class Announcement < Edition
  include Edition::Images
  include Edition::RelatedPolicies
  include Edition::WorldLocations
  include Edition::TopicalEvents

  def self.sti_names
    ([self] + descendants).map { |model| model.sti_name }
  end

  def search_format_types
    super + [Announcement.search_format_type]
  end
end

require_relative 'news_article'
require_relative 'speech'
require_relative 'fatality_notice'
