require "test_helper"

class StandardEdition::LeadImageTest < ActiveSupport::TestCase
  setup do
    @img_one = create(:featured_image_data, file: File.open(Rails.root.join("test/fixtures/minister-of-funk.960x640.jpg")))
    @img_two = create(:featured_image_data, file: File.open(Rails.root.join("test/fixtures/big-cheese.960x640.jpg")))
    @img_three = create(:featured_image_data, file: File.open(Rails.root.join("test/fixtures/images/960x640_gif.gif")))
    @lead_organisation_with_image = create(:organisation, default_news_image: @img_one)
    @lead_organisation_with_no_image = create(:organisation, default_news_image: nil)
    @supporting_organisation_with_image = create(:organisation, default_news_image: @img_two)
    @worldwide_organisation_with_image = create(:published_worldwide_organisation, default_news_image: @img_three)
  end

  test "it returns the default news image from the first lead organisation if present" do
    edition = build(:standard_edition, lead_organisations: [@lead_organisation_with_image])
    assert_equal @img_one, edition.default_lead_image
  end

  test "it returns the default news image from a supporting organisation if the first lead does not have an image" do
    edition = build(:standard_edition,
                    lead_organisations: [@lead_organisation_with_no_image],
                    organisations: [@supporting_organisation_with_image, @lead_organisation_with_no_image])
    assert_equal @img_two, edition.default_lead_image
  end

  test "it returns the default news image from the worldwide organisations if organisations are missing" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type_with_images_and_attachments", {}))
    edition = create(:standard_edition, configurable_document_type: "test_type_with_images_and_attachments", organisations: [])
    edition.edition_worldwide_organisations.create([{ document: @worldwide_organisation_with_image.document }])
    assert_equal @img_three, edition.default_lead_image
  end

  test "#placeholder_image_url returns world news placeholder for world news stories" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("world_news_story"))
    edition = build(:standard_edition, configurable_document_type: "world_news_story")
    assert_equal "https://assets.publishing.service.gov.uk/media/5e985599d3bf7f3fc943bbd8/UK_government_logo.jpg", edition.placeholder_image_url
  end

  test "#placeholder_image_url returns general placeholder for non-world news stories" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("news_article"))
    edition = build(:standard_edition, configurable_document_type: "news_article")
    assert_equal "https://assets.publishing.service.gov.uk/media/5e59279b86650c53b2cefbfe/placeholder.jpg", edition.placeholder_image_url
  end

  test "#lead_image_payload builds custom lead image" do
    default_lead_image = build(:featured_image_data)
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    lead_image = create(:image, usage: "lead", caption: "Lead image caption")
    edition = create(:standard_edition, images: [lead_image], organisations: [create(:organisation, default_news_image: default_lead_image)])
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    expected_payload = {
      url: lead_image.url,
      sources: {
        "s960" => lead_image.url("s960"),
        "s712" => lead_image.url("s712"),
        "s630" => lead_image.url("s630"),
        "s465" => lead_image.url("s465"),
        "s300" => lead_image.url("s300"),
        "s216" => lead_image.url("s216"),
      },
      caption: lead_image.caption,
      content_type: lead_image.content_type,
      type: "lead",
    }
    assert_equal expected_payload, edition.lead_image_payload(lead_usage)
  end

  test "#lead_image_payload sends a placeholder image if an svg is provided as lead (svgs not allowed as lead)" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    lead_image = create(:image, :svg, usage: "lead", caption: "Lead image caption")
    edition = create(:standard_edition, images: [lead_image])
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    expected_payload = {
      url: edition.placeholder_image_url,
      content_type: "image/jpeg",
      type: "lead",
    }
    assert_equal expected_payload, edition.lead_image_payload(lead_usage)
  end

  test "#lead_image_payload does not include a caption, if caption is nil" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    lead_image = create(:image, usage: "lead", caption: nil)
    edition = create(:standard_edition, images: [lead_image])
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    expected_payload = {
      url: lead_image.url,
      sources: {
        "s960" => lead_image.url("s960"),
        "s712" => lead_image.url("s712"),
        "s630" => lead_image.url("s630"),
        "s465" => lead_image.url("s465"),
        "s300" => lead_image.url("s300"),
        "s216" => lead_image.url("s216"),
      },
      content_type: lead_image.content_type,
      type: "lead",
    }
    assert_equal expected_payload, edition.lead_image_payload(lead_usage)
  end

  test "#lead_image_payload builds the default lead image payload if there is no custom lead image" do
    default_lead_image = build(:featured_image_data)
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    edition = create(:standard_edition, images: [], organisations: [create(:organisation, default_news_image: default_lead_image)])
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    expected_payload = {
      sources: {
        "s960" => default_lead_image.url("s960"),
        "s712" => default_lead_image.url("s712"),
        "s630" => default_lead_image.url("s630"),
        "s465" => default_lead_image.url("s465"),
        "s300" => default_lead_image.url("s300"),
        "s216" => default_lead_image.url("s216"),
      },
      content_type: default_lead_image.content_type,
      type: "lead",
    }
    assert_equal expected_payload, edition.lead_image_payload(lead_usage)
  end

  test "#lead_image_payload returns the placeholder image url if selected image's assets are missing" do
    default_lead_image = build(:featured_image_data)
    lead_image = create(:image, usage: "lead")
    lead_image.image_data.assets = []
    lead_image.image_data.save!
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    edition = create(:standard_edition, images: [lead_image], organisations: [create(:organisation, default_news_image: default_lead_image)])
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    expected_payload = {
      url: edition.placeholder_image_url,
      content_type: "image/jpeg",
      type: "lead",
    }
    assert_equal expected_payload, edition.lead_image_payload(lead_usage)
  end

  test "#lead_image_payload returns the placeholder image url if there is no custom image and default lead image's assets are missing" do
    default_lead_image = build(:featured_image_data)
    default_lead_image.assets = []
    default_lead_image.save!
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    edition = create(:standard_edition, images: [], organisations: [create(:organisation, default_news_image: default_lead_image)])
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    expected_payload = {
      url: edition.placeholder_image_url,
      content_type: "image/jpeg",
      type: "lead",
    }
    assert_equal expected_payload, edition.lead_image_payload(lead_usage)
  end

  test "#lead_image_payload returns the placeholder image url if there is no custom lead, and no default" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", lead_image_usage_test_type))
    edition = create(:standard_edition, images: [], organisations: [create(:organisation, default_news_image: nil)])
    lead_usage = edition.permitted_image_usages.find { |usage| usage.key == "lead" }

    expected_payload = {
      url: edition.placeholder_image_url,
      content_type: "image/jpeg",
      type: "lead",
    }
    assert_equal expected_payload, edition.lead_image_payload(lead_usage)
  end

  def lead_image_usage_test_type
    {
      "settings" => {
        "images" => {
          "enabled" => true,
          "usages" => {
            "lead" => {
              "kinds" => %w[default],
              "multiple" => false,
            },
          },
        },
      },
    }
  end
end
