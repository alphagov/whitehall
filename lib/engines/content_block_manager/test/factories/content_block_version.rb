FactoryBot.define do
  factory :content_block_version, class: "ContentBlockManager::ContentBlock::Version" do
    event { "created" }
    item do
      build(
        :content_block_edition,
        document: build(
          :content_block_document,
          block_type: "pension",
        ),
      )
    end
    whodunnit { build(:user).id }
    state {}
  end
end
