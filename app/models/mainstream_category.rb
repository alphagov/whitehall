require 'cgi'

class MainstreamCategory < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  has_many :primary_detailed_guides, class_name: "DetailedGuide",
           foreign_key: "primary_mainstream_category_id"
  has_many :edition_mainstream_categories
  has_many :other_detailed_guides, through: :edition_mainstream_categories,
           source: :edition, class_name: "DetailedGuide"

  validates :title, :identifier, :parent_title, presence: true
  before_save :update_slug!
  validates :identifier, format: {with: /^http(s?):\/\//, message: "must start with http or https"}
  validates :identifier, format: {with: /\.json$/, message: "must end with .json"}
  validates :identifier, format: {with: /\/tags\//, message: "must contain /tags/"}

  def detailed_guides
    primary_detailed_guides + other_detailed_guides
  end

  def published_detailed_guides
    primary_detailed_guides.published + other_detailed_guides.published
  end

  def to_param
    slug
  end

  def update_slug!
    self.slug = generate_slug
  end

  def generate_slug
    path.split("/").last
  end

  def path
    CGI::unescape(identifier.match(%r{^https?://[^/]+/tags/([^/]+)\.json$})[1])
  end

  def to_artefact_hash
    {
      title: title,
      id: path,
      web_url: nil,
      details: {
        type: 'section'
      },
      content_with_tag: {
        id: path,
        web_url: mainstream_category_path(self)
      }
    }
  end
end
