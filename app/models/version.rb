class Version < ApplicationRecord
  belongs_to :item, polymorphic: true
  validates :event, presence: true
  belongs_to :user, foreign_key: "whodunnit"

  def self.with_item_keys(item_type, item_id)
    where(item_type:, item_id:)
  end

  scope :preceding, ->(version) { where(["id < ?", version.id]).order("id DESC") }

  def sibling_versions
    self.class.with_item_keys(item_type, item_id)
  end

  def previous
    sibling_versions.preceding(self).first
  end

  public :to_ary
end
