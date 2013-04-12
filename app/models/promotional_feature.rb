class PromotionalFeature < ActiveRecord::Base
  belongs_to :organisation
  has_many :promotional_feature_items, inverse_of: :promotional_feature, dependent: :destroy

  validates_presence_of :organisation, :title

  def items
    promotional_feature_items
  end

  def has_reached_item_limit?
    items.count == 3 || has_one_small_and_one_large_item?
  end

  private

  def has_one_small_and_one_large_item?
    items.count == 2 && items.one? {|i| i.double_width? }
  end
end
