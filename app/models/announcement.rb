# @abstract
class Announcement < Edition
  include Edition::Images
  include Edition::RelatedPolicies
  include Edition::WorldLocations
  include Edition::TopicalEvents
  include Edition::Topics
  include Edition::WorldwidePriorities

  def self.sti_names
    ([self] + descendants).map { |model| model.sti_name }
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
