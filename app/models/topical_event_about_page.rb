class TopicalEventAboutPage < ApplicationRecord
  include PublishesToPublishingApi

  belongs_to :topical_event

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 255 } # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :read_more_link_text, presence: true, length: { maximum: 255 }
  validates :summary, presence: true, length: { maximum: (16.megabytes - 1) }
  validates :body, presence: true, length: { maximum: (16.megabytes - 1) }

  validates_with SafeHtmlValidator
  validates_with NoFootnotesInGovspeakValidator, attribute: :body

  after_commit :republish_topical_event_to_publishing_api

  def base_path
    "/government/topical-events/#{topical_event.slug}/about"
  end

  def public_path(options = {})
    append_url_options(base_path, options)
  end

  def public_url(options = {})
    Plek.website_root + public_path(options)
  end

  def republish_topical_event_to_publishing_api
    Whitehall::PublishingApi.republish_async(topical_event)
  end

  def publishing_api_presenter
    PublishingApi::TopicalEventAboutPagePresenter
  end
end
