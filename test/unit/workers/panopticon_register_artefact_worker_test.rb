require 'test_helper'

class PanopticonRegisterArtefactWorkerTest < ActiveSupport::TestCase
  test "registers an artefact with Panopticon" do
    edition = create(:published_edition)

    mock_registerable_edition = mock("RegisterableEdition")
    mock_registerable_edition.expects(:kind).returns("detailed_guide")
    RegisterableEdition.expects(:new).with(edition).returns(mock_registerable_edition)

    mock_registerer = mock("GdsApi::Panopticon::Registerer")
    mock_registerer.expects(:register).with(mock_registerable_edition)
    GdsApi::Panopticon::Registerer.expects(:new).with(has_entry(kind: "detailed_guide")).returns(mock_registerer)

    PanopticonRegisterArtefactWorker.new.perform(edition.id)
  end
end
