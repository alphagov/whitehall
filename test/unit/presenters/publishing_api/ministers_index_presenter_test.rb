require "test_helper"

class PublishingApi::MinistersIndexPresenterTest < ActionView::TestCase
  def presented_item
    PublishingApi::MinistersIndexPresenter.new
  end

  test "presenter is valid against ministers index schema" do
    I18n.with_locale(:en) do
      create(:sitewide_setting, key: :minister_reshuffle_mode, on: true)

      assert_valid_against_schema(presented_item.content, "ministers_index")
    end
  end

  test "presents ministers index page ready for the publishing-api in english" do
    I18n.with_locale(:en) do
      create(:sitewide_setting, key: :minister_reshuffle_mode, on: false)

      expected_hash = {
        title: "ministers_index",
        locale: "en",
        publishing_app: "whitehall",
        redirects: [],
        update_type: "major",
        base_path: "/government/ministers",
        details: {},
        document_type: "ministers_index",
        rendering_app: "whitehall-frontend",
        schema_name: "ministers_index",
        routes: [
          {
            path: "/government/ministers",
            type: "exact",
          },
        ],
      }

      assert_equal expected_hash, presented_item.content
    end
  end

  test "presents ministers index page ready for the publishing-api with correct reshuffle message" do
    I18n.with_locale(:en) do
      create(:sitewide_setting, key: :minister_reshuffle_mode, on: true)

      expected_details = {
        reshuffle: {
          message: "example text",
        },
      }

      assert_equal expected_details, presented_item.content[:details]
    end
  end

  test "presents ministers index page ready for the publishing-api in welsh" do
    I18n.with_locale(:cy) do
      create(:sitewide_setting, key: :minister_reshuffle_mode, on: false)

      expected_hash = {
        title: "ministers_index",
        locale: "cy",
        publishing_app: "whitehall",
        redirects: [],
        update_type: "major",
        base_path: "/government/ministers.cy",
        details: {},
        document_type: "ministers_index",
        rendering_app: "whitehall-frontend",
        schema_name: "ministers_index",
        routes: [
          {
            path: "/government/ministers.cy",
            type: "exact",
          },
        ],
      }

      assert_equal expected_hash, presented_item.content
    end
  end
end
