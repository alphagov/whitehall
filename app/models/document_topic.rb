class DocumentTopic < ActiveRecord::Base
  belongs_to :document
  belongs_to :topic

  default_scope order("document_topics.ordering ASC")
end