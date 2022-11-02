require "test_helper"

class SearchRake < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown do
    task.reenable # without this, calling `invoke` does nothing after first test
  end

  let(:task) { Rake::Task["search:resend_organisation"] }

  test "updates an organisation in search" do
    organisation = create(:organisation)

    Whitehall::SearchIndex.expects(:add).with(organisation)

    task.invoke(organisation.content_id)
  end
end
