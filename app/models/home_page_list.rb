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

  def self.get(opts = {})
    owner = opts[:owned_by]
    name = opts[:called]
    create_if_missing = opts.has_key?(:create_if_missing) ? opts[:create_if_missing] : true
    raise ArgumentError, "Must supply owned_by: and called: options" if (owner.nil? || name.nil?)
    scoping = where(owner_id: owner.id, owner_type: owner.class, name: name)
    if list = scoping.first
      list
    elsif create_if_missing
      scoping.create!
    end
  end

  protected
  def next_ordering
    (home_page_list_items.map(&:ordering).max || 0) + 1
  end

  def ensure_ordering!(new_item)
    new_item.ordering = next_ordering unless new_item.ordering
  end

end
