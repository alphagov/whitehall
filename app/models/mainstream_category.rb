require 'cgi'

class MainstreamCategory < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  has_many :primary_detailed_guides, class_name: "DetailedGuide",
           foreign_key: "primary_mainstream_category_id"
  has_many :edition_mainstream_categories
  has_many :other_detailed_guides, through: :edition_mainstream_categories,
           source: :edition, class_name: "DetailedGuide"

  validates :title, :parent_title, :parent_tag, :slug, presence: true

  def detailed_guides
    primary_detailed_guides + other_detailed_guides
  end

  def published_detailed_guides
    primary_detailed_guides.published + other_detailed_guides.published
  end

  def to_param
    slug
  end

  def path
    parent_tag + "/" + slug
  end

  def section
    parent_tag.split("/").first
  end

  def subsection
    parent_tag.split("/").last
  end

  def subsubsection
    slug
  end

end
