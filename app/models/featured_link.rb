class FeaturedLink < ActiveRecord::Base
  extend ActiveSupport::Concern

  belongs_to :linkable, polymorphic: true

  validates :url, :title, presence: true
  validates :url, uri: true

  def only_the_initial_set
    limit(5)
  end
end
