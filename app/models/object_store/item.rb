module ObjectStore
  class Item < Edition
    store_accessor :details, :item_type

    after_initialize :add_field_accessors

    validates :item_type, presence: true, on: :create
    validate :item_type_cannot_change
    validates :item_type, inclusion: { in: ObjectStore.item_types }

    def summary_required?
      false
    end

    def body_required?
      false
    end

    def previously_published
      false
    end

  private

    def add_field_accessors
      properties = ObjectStore.fields_for_item_type(item_type)
      properties.each_key do |k|
        singleton_class.class_eval { store_accessor :details, k }
        if ObjectStore.field_is_required?(item_type, k)
          singleton_class.class_eval { validates k, presence: true }
        end
      end
    rescue UnknownItemType
      # Ignored
    end

    def item_type_cannot_change
      if persisted? && item_type_changed?
        errors.add :item_type, "cannot be changed after creation"
      end
    end
  end
end
