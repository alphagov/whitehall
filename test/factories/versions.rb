FactoryBot.define do
  factory :version do
    event { "update" }

    transient do
      item { nil }
    end

    item_id { item.id }
    item_type { item.class.name }
  end
end
