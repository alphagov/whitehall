require "test_helper"

class PublishingApi::MinistersIndexEnableReshufflePresenterTest < ActionView::TestCase
  def presented_item
    PublishingApi::MinistersIndexEnableReshufflePresenter.new
  end

  test "presents a valid content item without information" do
    I18n.with_locale(:en) do
      create(
        :sitewide_setting,
        key: :minister_reshuffle_mode,
        on: true,
        govspeak: "Check [latest appointments](/government/news/ministerial-appointments-february-2023).",
      )

      expected_details = {
        reshuffle: {
          message: "<p>Check <a href=\"/government/news/ministerial-appointments-february-2023\" class=\"govuk-link\">latest appointments</a>.</p>\n",
        },
      }

      expected_links = {
        ordered_cabinet_ministers: [],
        ordered_also_attends_cabinet: [],
        ordered_ministerial_departments: [],
        ordered_house_of_commons_whips: [],
        ordered_junior_lords_of_the_treasury_whips: [],
        ordered_assistant_whips: [],
        ordered_house_lords_whips: [],
        ordered_baronesses_and_lords_in_waiting_whips: [],
      }

      assert_equal expected_details, presented_item.content[:details]
      assert_valid_against_publisher_schema(presented_item.content, "ministers_index")

      assert_equal expected_links, presented_item.links
      assert_valid_against_links_schema({ links: presented_item.links }, "ministers_index")
    end
  end
end
