module Document::Topics
  extend ActiveSupport::Concern

  included do
    has_many :document_topics, foreign_key: :document_id
    has_many :topics, through: :document_topics
  end

  def can_be_associated_with_topics?
    true
  end
  
  module ClassMethods
    def in_topic(topic)
      joins(:topics).where('topics.id' => topic)
    end
  end
end