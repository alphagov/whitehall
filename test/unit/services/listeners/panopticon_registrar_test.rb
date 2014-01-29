require 'test_helper'

class ServiceListeners::PanopticonRegistrarTest < ActiveSupport::TestCase

  test "registers a DetailedGuide with panopticon" do
    edition = create(:published_detailed_guide)
    PanopticonRegisterArtefactWorker.expects(:perform_async).with(edition.id).once
    ServiceListeners::PanopticonRegistrar.new(edition).register!
  end

  test "does not register other document types" do
    edition = build(:published_publication)
    PanopticonRegisterArtefactWorker.expects(:perform_async).never
    ServiceListeners::PanopticonRegistrar.new(edition).register!
  end
end
