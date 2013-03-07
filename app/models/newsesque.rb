class Newsesque < Announcement
  include Edition::FactCheckable
  include Edition::FirstImagePulledOut

  def self.sti_names
    ([self] + descendants).map { |model| model.sti_name }
  end

  def apply_any_extra_validations_when_converting_from_imported_to_draft
    class << self
      validates :first_published_at, presence: true
    end
  end
end

require_relative 'news_article'
require_relative 'world_location_news_article'
