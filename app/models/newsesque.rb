# @abstract
class Newsesque < Announcement
  include Edition::FactCheckable
  include Edition::FirstImagePulledOut

  validates :first_published_at, presence: true, if: -> e { e.trying_to_convert_to_draft == true }

  def self.sti_names
    ([self] + descendants).map { |model| model.sti_name }
  end

  def translatable?
    !non_english_edition?
  end
end

require_relative 'news_article'
require_relative 'world_location_news_article'
