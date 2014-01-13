class TopicSuggestion < ActiveRecord::Base
  belongs_to :edition

  validate :name, :edition, presence: true
end
