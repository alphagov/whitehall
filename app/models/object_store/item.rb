module ObjectStore
  class Item < Edition
    store_accessor :details, :item_type

    after_initialize :add_field_accessors

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
  end
end
