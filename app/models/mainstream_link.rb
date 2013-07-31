class MainstreamLink < ActiveRecord::Base
  belongs_to :linkable, polymorphic: true

  validates :url, :title, presence: true
  validates :url, uri: true

  DEFAULT_INITIAL_SET_SIZE = 5

  def self.only_the_initial_set(set_size = MainstreamLink::DEFAULT_INITIAL_SET_SIZE)
    limit(set_size)
  end
end
