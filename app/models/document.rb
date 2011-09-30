class Document < ActiveRecord::Base
  has_many :editions

  def self.published
    Edition.published.includes(:document).map(&:document)
  end

  def published_edition
    editions.published.first
  end
end