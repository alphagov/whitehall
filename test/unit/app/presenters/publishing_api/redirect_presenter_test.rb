require "test_helper"

class PublishingApi::RedirectPresenterTest < ActiveSupport::TestCase
  def present(...)
    PublishingApi::RedirectPresenter.new(...)
  end

  test "presents an item as a redirect to the publishing API" do
    item = create(
      :corporate_information_page,
      :published,
      organisation: nil,
      worldwide_organisation: create(:worldwide_organisation),
      corporate_information_page_type_id: CorporateInformationPageType::AboutUs.id,
    )

    expected_hash = {
      locale: "en",
      publishing_app: "whitehall",
      redirects: [{
        path: item.base_path,
        type: "exact",
        destination: item.api_presenter_redirect_to,
      }],
      update_type: "major",
      base_path: item.base_path,
      document_type: "redirect",
      schema_name: "redirect",
    }

    presented_item = present(item)

    assert_equal item.content_id, presented_item.content_id
    assert_equal expected_hash, presented_item.content
    assert_equal presented_item.links, {}
    assert_valid_against_publisher_schema(presented_item.content, "redirect")
  end

  test "presents an item as a redirect to publishing API when translated" do
    I18n.with_locale(:ar) do
      item = create(
        :corporate_information_page,
        :published,
        organisation: nil,
        worldwide_organisation: create(:worldwide_organisation),
        corporate_information_page_type_id: CorporateInformationPageType::AboutUs.id,
      )

      expected_hash = {
        locale: "ar",
        publishing_app: "whitehall",
        redirects: [{
          path: item.public_path(locale: I18n.locale),
          type: "exact",
          destination: item.api_presenter_redirect_to,
        }],
        update_type: "major",
        base_path: item.public_path(locale: I18n.locale),
        document_type: "redirect",
        schema_name: "redirect",
      }

      presented_item = present(item)

      assert_equal item.content_id, presented_item.content_id
      assert_equal expected_hash, presented_item.content
      assert_equal presented_item.links, {}
      assert_valid_against_publisher_schema(presented_item.content, "redirect")
    end
  end
end
