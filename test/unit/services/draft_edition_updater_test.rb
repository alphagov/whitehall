require 'test_helper'

class DraftEditionUpdaterTest < ActiveSupport::TestCase

  test "#perform! calls notify! without modifying the edition" do
    edition = create(:draft_edition)
    edition.freeze
    updater = DraftEditionUpdater.new(edition)
    updater.expects(:notify!).once

    updater.perform!
  end
end
