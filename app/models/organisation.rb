class Organisation < ActiveRecord::Base
  has_many :edition_organisations
  has_many :editions, through: :edition_organisations
  has_many :roles
  has_many :people, through: :roles

  validates :name, presence: true, uniqueness: true

  def published_policies
    published_documents.select { |document| document.is_a?(Policy) }
  end

  def published_publications
    published_documents.select { |document| document.is_a?(Publication) }
  end

  def published_documents
    editions.published.includes(:document).map(&:document)
  end
end