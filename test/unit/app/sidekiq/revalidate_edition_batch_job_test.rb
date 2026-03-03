require "test_helper"

class RevalidateEditionBatchJobTest < ActiveSupport::TestCase
  test "calls `valid?(:publish)` on the given editions" do
    edition1 = create(:edition)
    edition2 = create(:edition)

    Edition.any_instance.expects(:valid?).with(:publish).twice

    RevalidateEditionBatchJob.new.perform([edition1.id, edition2.id])
  end
end
