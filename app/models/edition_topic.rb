class EditionTopic < ActiveRecord::Base
  belongs_to :edition
  belongs_to :topic
end