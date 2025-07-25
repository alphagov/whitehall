require "test_helper"

class Admin::DetailedGuidesControllerTest < ActionController::TestCase
  class NationalApplicabilityTest < ActionController::TestCase
    tests Admin::DetailedGuidesController

    setup do
      login_as(:writer)

      stub_request(
        :get,
        %r{\A#{Plek.find('publishing-api')}/v2/links},
      ).to_return(body: { links: {} }.to_json)
    end

    include TestsForNationalApplicability

  private

    def edition_class
      DetailedGuide
    end
  end
end
