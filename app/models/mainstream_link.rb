class MainstreamLink < ActiveRecord::Base
  belongs_to :linkable, polymorphic: true

  validates :url, :title, presence: true
  validates :url, format: URI::regexp(%w(http https))

  DEFAULT_INITIAL_SET_SIZE = 5

  def self.in_creation_order
    order(:created_at)
  end

  def self.only_the_initial_set(set_size = MainstreamLink::DEFAULT_INITIAL_SET_SIZE)
    in_creation_order.limit(set_size)
  end
end
