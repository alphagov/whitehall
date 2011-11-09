module Document::Topics
  extend ActiveSupport::Concern

  class Trait < Document::Traits::Trait
    def assign_associations_to(document)
      document.document_topics = @document.document_topics.map do |dt|
        DocumentTopic.new(dt.attributes.except(:id))
      end
    end
  end

  included do
    has_many :document_topics, foreign_key: :document_id
    has_many :topics, through: :document_topics

    add_trait Trait
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