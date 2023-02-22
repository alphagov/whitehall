class OperationalField < ApplicationRecord
  include PublishesToPublishingApi
  include Searchable

  validates :name, presence: true, uniqueness: { case_sensitive: false } # rubocop:disable Rails/UniqueValidationWithoutIndex

  has_many :fatality_notices

  searchable title: :name,
             link: :search_link,
             content: :description_without_markup

  extend FriendlyId
  friendly_id

  def search_link
    Whitehall.url_maker.operational_field_path(slug)
  end

  def description_without_markup
    Govspeak::Document.new(description).to_text
  end

  def published_fatality_notices
    fatality_notices.published
  end

  def base_path
    "/government/fields-of-operation/#{slug}"
  end

  def public_path(options = {}, locale:)
    append_url_options(base_path, options, locale:)
  end

  def public_url(options = {}, locale:)
    Plek.website_root + public_path(options, locale:)
  end
end
