module AdminEditionController
  module GovspeakHistoryAndFactCheckingTabsTests
    extend ActiveSupport::Concern

    included do
      view_test "GET :show renders a side nav bar with history and fact checking" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang
        stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

        fact_checking_view_component = Admin::Editions::FactCheckingTabComponent.new(edition:)
        Admin::Editions::FactCheckingTabComponent.expects(:new).with { |value|
          value[:edition].title == edition.title && value[:send_request_section] == true
        }.returns(fact_checking_view_component)

        get :show, params: { id: edition }

        assert_select ".govuk-tabs__tab", text: "History"
        assert_select ".govuk-tabs__tab", text: "Fact checking"
      end

      view_test "GET :edit renders a side nav bar with govspeak help, history and fact checking" do
        edition = create(edition_type) # rubocop:disable Rails/SaveBang
        stub_publishing_api_expanded_links_with_taxons(edition.content_id, [])

        fact_checking_view_component = Admin::Editions::FactCheckingTabComponent.new(edition:)
        Admin::Editions::FactCheckingTabComponent.expects(:new).with { |value|
          value[:edition].title == edition.title
        }.returns(fact_checking_view_component)

        get :edit, params: { id: edition }

        assert_select ".govuk-tabs__tab", text: "Help"
        assert_select ".govuk-tabs__tab", text: "History"
        assert_select ".govuk-tabs__tab", text: "Fact checking"
      end
    end
  end
end
