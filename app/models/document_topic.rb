class DocumentTopic < ActiveRecord::Base
  belongs_to :document
  belongs_to :topic

  validates :document, :topic, presence: true

  default_scope order("document_topics.ordering ASC")

  class << self
    def published
      joins(:document).where("documents.state" => "published")
    end

    def for_type(type)
      joins(:document).where("documents.type" => type)
    end
  end
end