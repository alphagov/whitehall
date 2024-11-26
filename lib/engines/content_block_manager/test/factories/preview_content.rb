FactoryBot.define do
  factory :preview_content, class: "ContentBlockManager::PreviewContent" do
    title { "Example Title" }
    html { "<p>Example HTML</p>" }
    instances_count { 3 }

    initialize_with do
      new(title:, instances_count:, html:)
    end
  end
end
