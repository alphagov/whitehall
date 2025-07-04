require "test_helper"

class RevalidateEditionWorkerTest < ActiveSupport::TestCase
  test "calls `valid?(:publish)` on the given edition" do
    edition = create(:edition)

    Edition.any_instance.expects(:valid?).with(:publish).once

    RevalidateEditionWorker.new.perform(edition.id)
  end
end
