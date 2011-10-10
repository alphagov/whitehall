class DocumentTopic < ActiveRecord::Base
  belongs_to :document
  belongs_to :topic
end