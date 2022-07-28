require "test_helper"

class UpdateLiveAndLatestEditionIdTest < ActiveSupport::TestCase
  setup do
    @document = create(:document)
    @published_edition = create(:edition, :published, document: @document)
    @withdrawn_edition = create(:edition, :withdrawn, document: @document)
    @deleted_edition = create(:edition, :deleted, document: @document)
    @document.update!(live_edition_id: nil, latest_edition_id: nil)
  end

  test "updates live_edition_id to the most recent publicly_visible editions id" do
    UpdateLiveAndLatestEditionId.new(@document).call
    assert_equal @document.live_edition_id, @withdrawn_edition.id
  end

  test "updates latest_edition_id to the most recent non-deleted edition" do
    UpdateLiveAndLatestEditionId.new(@document).call
    assert_equal @document.latest_edition_id, @withdrawn_edition.id
  end
end
