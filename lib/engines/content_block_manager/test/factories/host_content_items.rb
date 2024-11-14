FactoryBot.define do
  factory :host_content_items, class: "ContentBlockManager::HostContentItems" do
    total_pages { 1 }
    total { 10 }
    items { build_list(:host_content_item, 10) }

    initialize_with do
      new(total_pages:,
          total:,
          items:)
    end
  end
end
