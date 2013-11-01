# @abstract
class Announcement < Edition
  include Edition::Images
  include Edition::Organisations
  include Edition::RelatedPolicies
  include Edition::WorldLocations
  include Edition::TopicalEvents
  include Edition::Topics
  include Edition::WorldwidePriorities

  def self.sti_names
    ([self] + descendants).map { |model| model.sti_name }
  end

  def self.published_with_eager_loading(ids)
    self.published.with_translations.includes([:document, organisations: :translations]).where(id: ids)
  end

  def search_format_types
    super + [Announcement.search_format_type]
  end

  def presenter
    AnnouncementPresenter
  end
end

require_relative 'newsesque'
require_relative 'speech'
require_relative 'fatality_notice'
