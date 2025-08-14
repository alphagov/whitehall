class Announcement < Edition
  include Edition::Images
  include Edition::Organisations
  include Edition::TaggableOrganisations
  include Edition::WorldLocations
  include Edition::TopicalEvents

  def presenter
    AnnouncementPresenter
  end

  def base_path
    "/government/news/#{slug}"
  end
end

require_relative "news_article"
require_relative "speech"
require_relative "fatality_notice"
