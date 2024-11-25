FactoryBot.define do
  factory :preview_content, class: "ContentBlockManager::PreviewContent" do
    title { "Example Title" }
    html { "<p>Example HTML</p>" }

    initialize_with do
      new(title:, html:)
    end
  end
end
