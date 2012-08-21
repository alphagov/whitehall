class DocumentSeries < ActiveRecord::Base
  belongs_to :organisation

  has_many :editions, order: 'published_at desc'

  validates :name, presence: true

  before_destroy { |dc| dc.destroyable? }

  extend FriendlyId
  friendly_id :name, use: :slugged

  def published_editions
    editions.published
  end

  protected

  def destroyable?
    editions.empty?
  end
end
