require 'test_helper'

class Admin::PoliciesControllerTest < ActionController::TestCase
  class NationalApplicabilityTest < ActionController::TestCase
    tests Admin::PoliciesController

    setup do
      login_as :policy_writer
    end

    include TestsForNationalApplicability

    private

    def edition_class
      Policy
    end

    def attributes_for_edition(attributes = {})
      o = create(:organisation_with_alternative_format_contact_email)
      super.merge({alternative_format_provider_id: o.id})
    end
  end
end
