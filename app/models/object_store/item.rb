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
      config = ObjectStore.item_type_by_name(item_type)
      config.fields.each do |field|
        singleton_class.class_eval { store_accessor :details, field.name }
        if field.required?
          singleton_class.class_eval { validates field.name, presence: true }
        end
      end
    rescue UnknownItemType
      # Ignored
    end
  end
end
