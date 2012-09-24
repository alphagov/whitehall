require 'cgi'

class MainstreamCategory < ActiveRecord::Base
  has_many :specialist_guides, foreign_key: "primary_mainstream_category_id"

  validates :title, :identifier, :parent_title, presence: true
  before_save :update_slug!

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
