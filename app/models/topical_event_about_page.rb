class TopicalEventAboutPage < ApplicationRecord
  include Searchable
  include PublishesToPublishingApi

  belongs_to :topical_event

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 255 } # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :read_more_link_text, presence: true, length: { maximum: 255 }
  validates :summary, presence: true, length: { maximum: (16.megabytes - 1) }
  validates :body, presence: true, length: { maximum: (16.megabytes - 1) }

  validates_with SafeHtmlValidator
  validates_with NoFootnotesInGovspeakValidator, attribute: :body

  searchable title: :name,
             link: :search_link,
             content: :indexable_content,
             description: :summary

  def search_link
    base_path
  end

  def indexable_content
    Govspeak::Document.new(body).to_text
  end

  def base_path
    "/government/topical-events/#{topical_event.slug}/about"
  end

  def public_path(options = {})
    locale = options[:locale] || "en"

    append_url_options(base_path, options, locale:)
  end

  def public_url(options = {})
    Plek.website_root + public_path(options)
  end
end
