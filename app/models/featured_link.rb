class FeaturedLink < ApplicationRecord
  extend ActiveSupport::Concern

  DEFAULT_SET_SIZE = 5

  belongs_to :linkable, polymorphic: true

  validates :url, :title, presence: true
  validates :url, uri: true

  def self.only_the_initial_set
    limit(DEFAULT_SET_SIZE)
  end
end
