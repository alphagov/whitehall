class TopicSuggestion < ActiveRecord::Base
  # TODO: Figure out if we need to add protection in the controllers with strong params
  # attr_accessible :name

  belongs_to :edition

  validate :name, :edition, presence: true
end
