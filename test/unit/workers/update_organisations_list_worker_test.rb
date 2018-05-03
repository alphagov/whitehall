require "test_helper"

class UpdateOrganisationsListWorkerTest < ActiveSupport::TestCase
  test "sends to the publishing api" do
    organisation = FactoryBot.create(:organisation)
    links = {
      ordered_executive_offices: [],
      ordered_ministerial_departments: [],
      ordered_non_ministerial_departments: [],
      ordered_agencies_and_other_public_bodies: [organisation.content_id],
      ordered_high_profile_groups: [],
      ordered_public_corporations: [],
      ordered_devolved_administrations: [],
    }

    Services.publishing_api.expects(:patch_links).with(
      "fde62e52-dfb6-42ae-b336-2c4faf068101",
      links: links
    )

    UpdateOrganisationsListWorker.new.perform
  end
end
