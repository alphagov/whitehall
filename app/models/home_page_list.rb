class HomePageList < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  has_many :home_page_list_items,
            -> { order :ordering },
            dependent: :destroy,
            before_add: :ensure_ordering!

  validates :owner, presence: true
  validates :name,
            presence: true,
            uniqueness: { scope: [:owner_id, :owner_type] },
            length: { maximum: 255 }

  def items
    home_page_list_items.includes(:item).map(&:item)
  end

  def self.get(opts = {})
    owner = opts[:owned_by]
    name = opts[:called]
    build_if_missing = opts.has_key?(:build_if_missing) ? opts[:build_if_missing] : true
    raise ArgumentError, "Must supply owned_by: and called: options" if (owner.nil? || name.nil?)
    scoping = where(owner_id: owner.id, owner_type: owner.class, name: name)
    if list = scoping.first
      list
    elsif build_if_missing
      scoping.build
    end
  end

  def shown_on_home_page?(item)
    items.include?(item)
  end

  def persist_if_required
    save! if new_record?
  end

  def add_item(item)
    persist_if_required
    home_page_list_items.create(item: item) unless shown_on_home_page?(item)
  end

  def remove_item(item)
    persist_if_required
    home_page_list_items.where(item_id: item.id, item_type: item.class).destroy_all
  end

  def reorder_items!(items_in_order)
    persist_if_required
    return if items_in_order.empty?
    HomePageListItem.transaction do
      home_page_list_items.each do |home_page_list_item|
        new_ordering = items_in_order.index(home_page_list_item.item)
        if new_ordering.nil?
          new_ordering = items_in_order.size
        end
        home_page_list_item.update_column(:ordering, new_ordering + 1)
      end
    end
  end

  def self.remove_from_all_lists(item)
    HomePageListItem.where(item_id: item.id, item_type: item.class).destroy_all
  end

  protected
  def next_ordering
    (home_page_list_items.map(&:ordering).max || 0) + 1
  end

  def ensure_ordering!(new_item)
    new_item.ordering = next_ordering unless new_item.ordering
  end

  public
  module Container
    # Given:
    #   has_home_page_list_of :contacts
    # Gives:
    #   has_home_page_contacts_list?
    #   contact_shown_on_home_page?
    #   home_page_contacts
    #   add_contact_to_home_page!
    #   remove_contact_from_home_page!
    #   reorder_contacts_on_home_page!
    #   a destroy hook to remove the list impl
    #   a protected home_page_contacts_list method to fetch the list impl
    # It uses a module so that you can override the methods and still
    # call super
    def has_home_page_list_of(list_type)
      single_name = list_type.to_s.singularize
      plural_name = list_type.to_s
      list_name = list_type.to_s
      home_page_list_methods = Module.new do
        protected
        define_method(:"home_page_#{plural_name}_list") do
          HomePageList.get(owned_by: self, called: list_name)
        end
        public
        define_method(:"has_home_page_#{plural_name}_list?") do
          HomePageList.get(owned_by: self, called: list_name, build_if_missing: false).present?
        end
        define_method(:"#{single_name}_shown_on_home_page?") do |contact|
          __send__(:"home_page_#{plural_name}_list").shown_on_home_page?(contact)
        end
        define_method(:"home_page_#{plural_name}") do
          __send__(:"home_page_#{plural_name}_list").items
        end
        define_method(:"add_#{single_name}_to_home_page!") do |contact|
          __send__(:"home_page_#{plural_name}_list").add_item(contact)
        end
        define_method(:"remove_#{single_name}_from_home_page!") do |contact|
          __send__(:"home_page_#{plural_name}_list").remove_item(contact)
        end
        define_method(:"reorder_#{plural_name}_on_home_page!") do |contacts|
          __send__(:"home_page_#{plural_name}_list").reorder_items!(contacts)
        end
        define_method(:"__remove_home_page_#{plural_name}_list") do
          __send__(:"home_page_#{plural_name}_list").destroy if __send__(:"has_home_page_#{plural_name}_list?")
        end
      end
      self.after_destroy :"__remove_home_page_#{plural_name}_list"
      include home_page_list_methods
    end
  end
  module ContentItem
    def is_stored_on_home_page_lists
      home_page_list_methods = Module.new do
        def __remove_home_page_list_items
          HomePageList.remove_from_all_lists(self)
        end
      end
      self.after_destroy :__remove_home_page_list_items
      include home_page_list_methods
    end
  end
end
