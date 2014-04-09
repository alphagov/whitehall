module FeaturedLink
  extend ActiveSupport::Concern

  included do
    belongs_to :linkable, polymorphic: true

    validates :url, :title, presence: true
    validates :url, uri: true
  end

  module ClassMethods
    def only_the_initial_set(set_size = default_set_size)
      limit(set_size)
    end

    def default_set_size
      5
    end
  end
end
