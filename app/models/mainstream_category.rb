require 'cgi'

class MainstreamCategory < ActiveRecord::Base
  has_many :primary_specialist_guides, class_name: "SpecialistGuide",
           foreign_key: "primary_mainstream_category_id"
  has_many :edition_mainstream_categories
  has_many :other_specialist_guides, through: :edition_mainstream_categories,
           source: :edition, class_name: "SpecialistGuide"

  validates :title, :identifier, :parent_title, presence: true
  before_save :update_slug!

  def specialist_guides
    primary_specialist_guides + other_specialist_guides
  end

  def published_specialist_guides
    primary_specialist_guides.published + other_specialist_guides.published
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
end
