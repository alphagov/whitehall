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

  after_commit :republish_operational_fields_index_page_to_publishing_api

  def republish_operational_fields_index_page_to_publishing_api
    PresentPageToPublishingApi.new.publish(PublishingApi::OperationalFieldsIndexPresenter)
  end

  def search_link
    public_path
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

  def public_path(options = {})
    append_url_options(base_path, options)
  end

  def public_url(options = {})
    Plek.website_root + public_path(options)
  end
end
