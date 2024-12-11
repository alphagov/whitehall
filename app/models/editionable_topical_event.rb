class EditionableTopicalEvent < Edition
  def display_type_key
    "editionable_topical_event"
  end

  def publishing_api_presenter
    PublishingApi::EditionableTopicalEventPresenter
  end

  def base_path
    "/government/editionable-topical-events/#{slug}"
  end

  def self.format_name
    "topical event"
  end
end
