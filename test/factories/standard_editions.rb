FactoryBot.define do
  factory :standard_edition, class: StandardEdition, parent: :edition do
    sequence(:title) { |index| "standard-edition-title-#{index}" }
    summary { "standard-edition-summary" }
    previously_published { false }
    configurable_document_type { "test_type" }
    block_content { {} }
    body { nil }

    factory :draft_standard_edition, parent: :standard_edition, traits: [:draft]
    factory :submitted_standard_edition, parent: :standard_edition, traits: [:submitted]
    factory :rejected_standard_edition, parent: :standard_edition, traits: [:rejected]
    factory :published_standard_edition, parent: :standard_edition, traits: [:published]
    factory :deleted_standard_edition, parent: :standard_edition, traits: [:deleted]
    factory :superseded_standard_edition, parent: :standard_edition, traits: [:superseded]
    factory :scheduled_standard_edition, parent: :standard_edition, traits: [:scheduled]
    factory :unpublished_standard_edition, parent: :standard_edition, traits: [:unpublished]
    factory :unpublished_standard_edition_in_error_no_redirect,
            parent: :standard_edition,
            traits: %i[published_in_error_no_redirect]
    factory :unpublished_standard_edition_in_error_redirect,
            parent: :standard_edition,
            traits: %i[published_in_error_redirect]
    factory :unpublished_standard_edition_consolidated,
            parent: :standard_edition,
            traits: %i[consolidated_redirect]
    factory :withdrawn_standard_edition, parent: :standard_edition, traits: [:withdrawn]

    factory :news_story, parent: :standard_edition do
      configurable_document_type { "news_story" }
      alternative_format_provider { build(:organisation, :with_alternative_format_contact_email) }
      transient do
        body { nil }
      end

      after(:build) do |edition, evaluator|
        body_content = evaluator.body || "Sample news story content"
        edition.block_content = { "body" => body_content }
        ConfigurableDocumentType.setup_test_types("news_story" => JSON.parse(File.read(Rails.root.join("app/models/configurable_document_types/news_story.json"))))
      end

      factory :draft_news_story, traits: [:draft]
      factory :published_news_story, traits: [:published]
      factory :submitted_news_story, traits: [:submitted]
    end

    factory :press_release, parent: :standard_edition do
      configurable_document_type { "press_release" }
      alternative_format_provider { build(:organisation, :with_alternative_format_contact_email) }
      transient do
        body { nil }
      end

      after(:build) do |edition, evaluator|
        body_content = evaluator.body || "Sample press release content"
        edition.block_content = { "body" => body_content }
        ConfigurableDocumentType.setup_test_types("press_release" => JSON.parse(File.read(Rails.root.join("app/models/configurable_document_types/press_release.json"))))
      end

      factory :draft_press_release, traits: [:draft]
      factory :published_press_release, traits: [:published]
      factory :submitted_press_release, traits: [:submitted]
    end

    factory :government_response, parent: :standard_edition do
      configurable_document_type { "government_response" }
      alternative_format_provider { build(:organisation, :with_alternative_format_contact_email) }
      transient do
        body { nil }
      end

      after(:build) do |edition, evaluator|
        body_content = evaluator.body || "Sample government response content"
        edition.block_content = { "body" => body_content }
        ConfigurableDocumentType.setup_test_types("government_response" => JSON.parse(File.read(Rails.root.join("app/models/configurable_document_types/government_response.json"))))
      end

      factory :draft_government_response, traits: [:draft]
      factory :published_government_response, traits: [:published]
      factory :submitted_government_response, traits: [:submitted]
    end

    factory :world_news_story, parent: :standard_edition do
      configurable_document_type { "world_news_story" }
      alternative_format_provider { build(:organisation, :with_alternative_format_contact_email) }
      transient do
        body { nil }
      end
      world_locations { [FactoryBot.create(:world_location)] }
      worldwide_organisations { [FactoryBot.create(:worldwide_organisation)] }

      after(:build) do |edition, evaluator|
        body_content = evaluator.body || "Sample world news story content"
        edition.block_content = { "body" => body_content }
        ConfigurableDocumentType.setup_test_types("world_news_story" => JSON.parse(File.read(Rails.root.join("app/models/configurable_document_types/world_news_story.json"))))
      end

      factory :draft_world_news_story, traits: [:draft]
      factory :published_world_news_story, traits: [:published]
      factory :submitted_world_news_story, traits: [:submitted]
    end

    factory :news_article, parent: :press_release, traits: [:with_organisations] do
      title { "news-title" }
      summary { "news-summary" }

      after(:build) do |edition, evaluator|
        body_content = evaluator.body || "news-body"
        edition.block_content = { "body" => body_content }
      end
      factory :draft_news_article, traits: [:draft]
      factory :published_news_article, traits: [:published]
      factory :submitted_news_article, traits: [:submitted]
      factory :rejected_news_article, traits: [:rejected]
      factory :superseded_news_article, traits: [:superseded]
      factory :withdrawn_news_article, traits: [:withdrawn]
      factory :news_article_news_story, parent: :news_story, traits: [:with_organisations]
      factory :news_article_press_release, parent: :press_release, traits: [:with_organisations]
      factory :news_article_government_response, parent: :government_response, traits: [:with_organisations]
      factory :news_article_world_news_story, parent: :world_news_story
    end
  end
end
