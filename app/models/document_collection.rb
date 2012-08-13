class DocumentCollection < ActiveRecord::Base
  belongs_to :organisation

  has_many :edition_document_collections
  has_many :editions, through: :edition_document_collections

  validates :name, presence: true

  before_destroy { |dc| dc.destroyable? }

  def published_editions
    editions.published
  end

  protected

  def destroyable?
    edition_document_collections.empty?
  end
end
