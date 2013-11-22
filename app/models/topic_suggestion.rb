class TopicSuggestion < ActiveRecord::Base
  attr_accessible :name

  belongs_to :edition

  validate :name, :edition, presence: true
end
