module DocumentControllerTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_redirect_json_in_english_locale
      view_test "index requested as JSON is redirected" do
        get :index, format: :json
        assert_response :redirect
      end
    end
  end

private

  def controller_attributes_for(edition_type, attributes = {})
    if edition_type.to_s.classify.constantize.new.can_be_related_to_organisations?
      attributes = attributes.merge(
        lead_organisation_ids: [(Organisation.first || create(:organisation)).id],
      )
    end

    attributes_for(edition_type, attributes).except(:attachments)
  end
end
