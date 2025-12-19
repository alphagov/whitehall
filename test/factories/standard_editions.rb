FactoryBot.define do
  factory :standard_edition, class: StandardEdition, parent: :edition do
    sequence(:title) { |index| "standard-edition-title-#{index}" }
    summary { "standard-edition-summary" }
    previously_published { false }
    configurable_document_type { "test_type" }
    block_content { { "body" => "Standard edition body content" } }
    body { nil }

    transient do
      organisations { [] }
      create_default_organisation { true }
    end

    after(:build) do |edition, evaluator|
      StandardEditionFactoryHelpers.assign_organisations_to_edition(edition, evaluator)
      StandardEditionFactoryHelpers.register_configurable_document_type(edition)
    end

    factory :draft_standard_edition, traits: [:draft]
    factory :submitted_standard_edition, traits: [:submitted]
    factory :rejected_standard_edition, traits: [:rejected]
    factory :published_standard_edition, traits: [:published]
    factory :deleted_standard_edition, traits: [:deleted]
    factory :superseded_standard_edition, traits: [:superseded]
    factory :scheduled_standard_edition, traits: [:scheduled]
    factory :unpublished_standard_edition, traits: [:unpublished]
    factory :unpublished_standard_edition_in_error_no_redirect, traits: [:published_in_error_no_redirect]
    factory :unpublished_standard_edition_in_error_redirect, traits: [:published_in_error_redirect]
    factory :unpublished_standard_edition_consolidated, traits: [:consolidated_redirect]
    factory :withdrawn_standard_edition, traits: [:withdrawn]

    factory :news_article do
      configurable_document_type { "press_release" }
      alternative_format_provider { build(:organisation, :with_alternative_format_contact_email) }

      transient do
        body { "Sample news article content" }
        organisations { [] }
      end

      after(:build) do |edition, evaluator|
        edition.block_content = { "body" => evaluator.body }
        StandardEditionFactoryHelpers.assign_organisations_to_edition(edition, evaluator)
        StandardEditionFactoryHelpers.add_world_news_story_defaults(edition) if edition.configurable_document_type == "world_news_story"
      end

      factory :draft_news_article, traits: [:draft]
      factory :published_news_article, traits: [:published]
      factory :submitted_news_article, traits: [:submitted]
      factory :rejected_news_article, traits: [:rejected]
      factory :superseded_news_article, traits: [:superseded]
      factory :withdrawn_news_article, traits: [:withdrawn]

      factory :news_article_news_story do
        configurable_document_type { "news_story" }
      end
      factory :news_article_press_release do
        configurable_document_type { "press_release" }
      end
      factory :news_article_government_response do
        configurable_document_type { "government_response" }
      end
      factory :news_article_world_news_story do
        configurable_document_type { "world_news_story" }
        transient do
          body { "Sample world news story content" }
        end
      end
    end
  end
end

module StandardEditionFactoryHelpers
  def self.assign_organisations_to_edition(edition, evaluator)
    if evaluator.organisations.any?
      edition.edition_organisations.clear
      evaluator.organisations.each_with_index do |org, index|
        edition.edition_organisations.build(
          edition: edition,
          organisation: org,
          lead_ordering: index + 1,
          lead: true,
        )
      end
    elsif edition.edition_organisations.empty? && evaluator.create_default_organisation
      edition.edition_organisations.build(
        edition: edition,
        organisation: FactoryBot.build(:organisation),
        lead_ordering: 1,
        lead: true,
      )
    end
  end

  def self.register_configurable_document_type(edition)
    return if edition.configurable_document_type == "test_type"

    config_file = Rails.root.join("app/models/configurable_document_types/#{edition.configurable_document_type}.json")
    if File.exist?(config_file)
      ConfigurableDocumentType.setup_test_types({
        edition.configurable_document_type => JSON.parse(File.read(config_file)),
      })
    end
  end

  def self.add_world_news_story_defaults(edition)
    if edition.worldwide_organisations.empty? && edition.worldwide_organisation_documents.empty?
      edition.worldwide_organisations = [FactoryBot.create(:worldwide_organisation)]
    end
    if edition.world_locations.empty?
      edition.world_locations = [FactoryBot.create(:world_location)]
    end
  end
end
