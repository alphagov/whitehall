module AdminEditionController::AlternativeFormatProviderTests
  extend ActiveSupport::Concern

  included do
    view_test "when creating allow selection of alternative format provider" do
      get :new

      assert_select "form#new_edition" do
        assert_select "select[name='edition[alternative_format_provider_id]']"
      end
    end

    view_test "when editing allow selection of alternative format provider" do
      draft = create("draft_#{edition_type}")

      get :edit, params: { id: draft }

      assert_select "form#edit_edition" do
        assert_select "select[name='edition[alternative_format_provider_id]']"
      end
    end

    test "update should save modified alternative format provider" do
      organisation = create(:organisation_with_alternative_format_contact_email)
      edition = create(edition_type) # rubocop:disable Rails/SaveBang

      put :update,
          params: {
            id: edition,
            edition: {
              alternative_format_provider_id: organisation.id,
            },
          }

      saved_edition = edition.reload
      assert_equal organisation, saved_edition.alternative_format_provider
    end
  end
end
