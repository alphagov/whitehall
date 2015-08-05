require 'test_helper'
require 'gds_api/panopticon'
require 'gds_api/test_helpers/panopticon'

class PanopticonRegisterArtefactWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Panopticon

  test "registers an artefact with Panopticon" do
    edition = create(:published_detailed_guide)
    request = stub_artefact_registration("guidance/#{edition.slug}")

    PanopticonRegisterArtefactWorker.new.perform(edition.id)

    assert_requested(request)
  end
end
