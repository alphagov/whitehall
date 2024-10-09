FactoryBot.define do
  factory :content_block_edition_organisation, class: "ContentBlockManager::ContentBlock::EditionOrganisation" do
    edition {}
    organisation {}
  end
end
