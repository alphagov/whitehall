FactoryBot.define do
  factory :object_store_item, class: ObjectStore::Item, parent: :edition do
    transient do
      item_type { "email_address" }
    end

    title { "object-store-item" }

    initialize_with { ObjectStore::Item.new(item_type:) }
  end
end
