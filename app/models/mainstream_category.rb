require 'cgi'

class MainstreamCategory < ActiveRecord::Base
  has_many :primary_detailed_guides, class_name: "DetailedGuide",
           foreign_key: "primary_mainstream_category_id"
  has_many :edition_mainstream_categories, dependent: :destroy
  has_many :other_detailed_guides, through: :edition_mainstream_categories,
           source: :edition, class_name: "DetailedGuide"

  validates :title, :parent_title, :parent_tag, :slug, presence: true

  def self.with_published_content
    where(%{
      EXISTS (
        SELECT e.id FROM editions e
        WHERE e.primary_mainstream_category_id = #{arel_table.name}.id
          AND e.state = 'published'
      ) OR EXISTS (
        SELECT e2.id FROM edition_mainstream_categories emc
        JOIN editions e2
          ON emc.edition_id = e2.id
          AND e2.state = 'published'
        WHERE emc.mainstream_category_id = #{arel_table.name}.id
      )
    })
  end

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
