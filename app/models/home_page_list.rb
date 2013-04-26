class HomePageList < ActiveRecord::Base
  belongs_to :owner,
             polymorphic: true
  validates :owner, presence: true
  validates :name, presence: true,
                   uniqueness: { scope: [:owner_id, :owner_type] },
                   length: { maximum: 255 }
  has_many :home_page_list_items,
           dependent: :destroy,
           order: :ordering,
           before_add: :ensure_ordering!
  def items
    home_page_list_items.includes(:item).map(&:item)
  end

  protected
  def next_ordering
    (home_page_list_items.map(&:ordering).max || 0) + 1
  end

  def ensure_ordering!(new_item)
    new_item.ordering = next_ordering unless new_item.ordering
  end

end
