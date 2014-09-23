require 'test_helper'

class ServiceListeners::PublishingApiRegistrarTest < ActiveSupport::TestCase

  test "registers an edition with the publishing api" do
    edition = create(:published_publication)
    PublishingApiRegisterArtefactWorker.expects(:perform_async).with(edition.id).once
    ServiceListeners::PublishingApiRegistrar.new(edition).register!
  end

end
