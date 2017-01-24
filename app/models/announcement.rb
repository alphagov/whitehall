# @abstract
class Announcement < Edition
  include Edition::Images
  include Edition::Organisations
  include Edition::TaggableOrganisations
  include Edition::RelatedPolicies
  include Edition::WorldLocations
  include Edition::TopicalEvents

  # DID YOU MEAN: Policy Area?
  # "Policy area" is the newer name for "topic"
  # (https://www.gov.uk/government/topics)
  # "Topic" is the newer name for "specialist sector"
  # (https://www.gov.uk/topic)
  # You can help improve this code by renaming all usages of this field to use
  # the new terminology.
  include Edition::Topics

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
