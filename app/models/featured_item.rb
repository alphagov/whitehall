# == Schema Information
#
# Table name: featured_items
#
#  id                                   :integer          not null, primary key
#  item_id                              :integer          not null
#  item_type                            :string(255)      not null
#  featured_topics_and_policies_list_id :integer
#  ordering                             :integer
#  started_at                           :datetime
#  ended_at                             :datetime
#

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

  def linkable_item
    case item
    when Topic
      item
    when Document
      item.published_edition
    end
  end

  def linkable?
    linkable_item.present?
  end

  def linkable_title
    case item
    when Topic
      item.name
    when Document
      item.published_edition.try(:title)
    end
  end

  private

  def set_started_at!
    self.started_at = Time.zone.now
  end
end
