module AdminEditionController::RelatedMainstreamContentTests
  extend ActiveSupport::Concern

  included do
    def edition_type_class
      self.class.class_for(edition_type)
    end

    view_test "new should display fields for related mainstream content" do
      get :new

      admin_editions_path = send("admin_#{edition_type.to_s.pluralize}_path")
      assert_select "form#new_edition[action='#{admin_editions_path}']" do
        assert_select "input[name*='edition[related_mainstream_content_url]']"
        assert_select "input[name*='edition[additional_related_mainstream_content_url]']"
      end
    end

    view_test "edit should display fields for related mainstream content" do
      edition = create(edition_type) # rubocop:disable Rails/SaveBang
      get :edit, params: { id: edition }

      admin_edition_path = send("admin_#{edition_type}_path", edition)
      assert_select "form#edit_edition[action='#{admin_edition_path}']" do
        assert_select "input[name*='edition[related_mainstream_content_url]']"
        assert_select "input[name*='edition[additional_related_mainstream_content_url]']"
      end
    end

    test "create should allow setting of related mainstream content urls" do
      Services.publishing_api.stubs(:lookup_content_ids).with(base_paths: ["/starting-to-export", "/vat-rates"]).returns("/starting-to-export" => "af70706d-1286-49a8-a597-b3715f29edb5", "/vat-rates" => "c621b246-aa0e-44ad-b320-5a9c16c1123b")

      post :create,
           params: {
             edition: controller_attributes_for(edition_type).merge(
               related_mainstream_content_url: "https://www.gov.uk/starting-to-export",
               additional_related_mainstream_content_url: "https://www.gov.uk/vat-rates",
             ),
           }

      edition = edition_type_class.last
      assert_equal "https://www.gov.uk/starting-to-export", edition.related_mainstream_content_url
      assert_equal "https://www.gov.uk/vat-rates", edition.additional_related_mainstream_content_url
    end

    test "update should allow setting of a related mainstream content url" do
      Services.publishing_api.stubs(:lookup_content_ids).with(base_paths: ["/starting-to-export", "/vat-rates"]).returns("/starting-to-export" => "af70706d-1286-49a8-a597-b3715f29edb5", "/vat-rates" => "c621b246-aa0e-44ad-b320-5a9c16c1123b")

      edition = create(
        edition_type,
        related_mainstream_content_url: "https://www.gov.uk/starting-to-export",
        additional_related_mainstream_content_url: "https://www.gov.uk/vat-rates",
      )
      Services.publishing_api.stubs(:lookup_content_ids).with(base_paths: ["/fishing-licences", "/set-up-business-uk"]).returns("/fishing-licences" => "bc46370c-2f2b-4db7-bf23-ace64b465eca", "/set-up-business-uk" => "5e5bb54d-e471-4d07-977b-291168569f26")

      put :update,
          params: {
            id: edition,
            edition: {
              related_mainstream_content_url: "https://www.gov.uk/fishing-licences",
              additional_related_mainstream_content_url: "https://www.gov.uk/set-up-business-uk",
            },
          }

      edition.reload
      assert_equal "https://www.gov.uk/fishing-licences", edition.related_mainstream_content_url
      assert_equal "https://www.gov.uk/set-up-business-uk", edition.additional_related_mainstream_content_url
    end
  end
end
