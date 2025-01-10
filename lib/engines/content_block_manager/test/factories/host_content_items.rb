FactoryBot.define do
  factory :host_content_items, class: "ContentBlockManager::HostContentItem::Items" do
    total_pages { 1 }
    total { 10 }
    items { build_list(:host_content_item, 10) }
    rollup { build(:rollup) }

    initialize_with do
      new(total_pages:,
          total:,
          items:,
          rollup:)
    end
  end

  factory :rollup, class: "ContentBlockManager::HostContentItem::Items::Rollup" do
    views { Random.rand(0..10) }
    locations { Random.rand(0..10) }
    instances { Random.rand(0..10) }
    organisations { Random.rand(0..10) }

    initialize_with do
      new(views:,
          locations:,
          instances:,
          organisations:)
    end
  end
end
