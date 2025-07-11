require "test_helper"

class RevalidateEditionBatchWorkerTest < ActiveSupport::TestCase
  test "calls `valid?(:publish)` on the given editions" do
    edition1 = create(:edition)
    edition2 = create(:edition)

    Edition.any_instance.expects(:valid?).with(:publish).twice

    RevalidateEditionBatchWorker.new.perform([edition1.id, edition2.id])
  end
end
