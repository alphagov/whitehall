class FeaturedTopicsAndPoliciesList < ActiveRecord::Base
  belongs_to :organisation

  validates :summary, length: { maximum: 65_535 }
  validates :organisation, presence: true

  has_many :featured_items, -> { order :ordering }, dependent: :destroy, before_add: :ensure_ordering!
  accepts_nested_attributes_for :featured_items, reject_if: :no_useful_featured_item_attributes?

  def current_and_linkable_featured_items
    featured_items.current.select { |item| item.linkable? }
  end

  protected
  def next_ordering
    (featured_items.map(&:ordering).max || 0) + 1
  end

  def ensure_ordering!(new_feature)
    new_feature.ordering = next_ordering unless new_feature.ordering
  end

  def no_useful_featured_item_attributes?(attrs)
    attrs.except(:item_type, :ordering, :featured_topics_and_policies_list).all? { |a, v| v.blank? }
  end
end
