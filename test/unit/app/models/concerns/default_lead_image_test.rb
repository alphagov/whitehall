require "test_helper"

class DefaultLeadImageTest < ActiveSupport::TestCase
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
end
