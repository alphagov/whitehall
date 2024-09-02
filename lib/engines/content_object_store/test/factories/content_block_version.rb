FactoryBot.define do
  factory :content_block_version, class: "ContentObjectStore::ContentBlock::Version" do
    event { "created" }
    item do
      create(
        :content_block_edition,
        document: create(
          :content_block_document,
          block_type: "email_address",
        ),
      )
    end
    whodunnit { create(:user).id }
    state {}
  end
end
