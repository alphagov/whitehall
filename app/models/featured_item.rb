class FeaturedItem < ActiveRecord::Base
  belongs_to :item, polymorphic: true
  belongs_to :featured_topics_and_policies_list

  validates :item, :featured_topics_and_policies_list, :started_at, presence: true

  before_validation :set_started_at!, on: :create

  def self.current
    where(ended_at: nil)
  end

  def topic_id
    if item.is_a?(Topic)
      item.id
    else
      nil
    end
  end

  def document_id
    if item.is_a?(Document)
      item.id
    else
      nil
    end
  end

  private

  def set_started_at!
    self.started_at = Time.zone.now
  end
end
