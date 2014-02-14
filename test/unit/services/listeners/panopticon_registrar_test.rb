require 'test_helper'

class ServiceListeners::PanopticonRegistrarTest < ActiveSupport::TestCase

  test "registers an edition with panopticon" do
    edition = create(:published_publication)
    PanopticonRegisterArtefactWorker.expects(:perform_async).with(edition.id).once
    ServiceListeners::PanopticonRegistrar.new(edition).register!
  end

end
