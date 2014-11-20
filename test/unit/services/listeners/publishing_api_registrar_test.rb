require 'test_helper'

class ServiceListeners::PublishingApiRegistrarTest < ActiveSupport::TestCase

  test "registers an edition with the publishing api" do
    edition = create(:published_publication)
    PublishingApiWorker.expects(:perform_async).with("Publication", edition.id).once
    ServiceListeners::PublishingApiRegistrar.new(edition).register!
  end
end
