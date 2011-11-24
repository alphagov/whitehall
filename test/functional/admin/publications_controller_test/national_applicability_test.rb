require 'test_helper'

class Admin::PublicationsControllerTest < ActionController::TestCase
  class NationalApplicabilityTest < ActionController::TestCase
    tests Admin::PublicationsController

    setup do
      login_as :policy_writer
    end

    include TestsForNationalApplicability

    private

    def document_class
      Publication
    end

    def attributes_for_document(attributes = {})
      super.merge(publication_metadatum_attributes: attributes_for(:publication_metadatum))
    end
  end
end
