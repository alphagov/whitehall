require 'test_helper'

class ServiceListeners::OrganisationPublishingApiRegistrarTest < ActiveSupport::TestCase

  test "registers an organisation with the publishing api" do
    organisation = create(:organisation)
    PublishingApiRegisterOrganisationWorker.expects(:perform_async).with(organisation.id).once
    ServiceListeners::OrganisationPublishingApiRegistrar.new(organisation).register!
  end

end
