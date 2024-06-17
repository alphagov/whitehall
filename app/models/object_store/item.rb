module ObjectStore
  class Item < ApplicationRecord
    include Edition::LiteEdition

    store_accessor :details, :item_type

    after_initialize :add_field_accessors

    validates :item_type, presence: true, on: :create
    validate :item_type_cannot_change
    validates :item_type, inclusion: { in: ObjectStore.item_types }

    def title_required?
      true
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

    def item_type_cannot_change
      if persisted? && item_type_changed?
        errors.add :item_type, "cannot be changed after creation"
      end
    end
  end
end
