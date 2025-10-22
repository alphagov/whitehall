require "test_helper"

class ReplaceableTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include ActionDispatch::TestProcess

  test "replace_with! won't let you replace an instance with itself" do
    self_referential = create(:attachment_data, attachable: build(:draft_publication, id: 1))
    assert_raise(ActiveRecord::RecordInvalid) do
      self_referential.replace_with!(self_referential)
    end
  end

  test "same_filename_as_replacement? returns true if replacement has same filename as self" do
    attachment_data = create(:attachment_data, attachable: build(:draft_publication, id: 1))
    replacement_attachment_data = create(:attachment_data, to_replace_id: attachment_data.id, attachable: build(:draft_publication, id: 1))

    assert replacement_attachment_data.same_filename_as_replacement?
  end

  test "replace_with! updates replaced_by_id of replaced" do
    attachment_data = create(:attachment_data, attachable: build(:draft_publication, id: 1))
    replacement_attachment_data = create(:attachment_data, attachable: build(:draft_publication, id: 1))

    attachment_data.replace_with!(replacement_attachment_data)

    assert_equal attachment_data.reload.replaced_by_id, replacement_attachment_data.id
  end

  test "handle_to_replace_id updates replaced_by_id of replaced" do
    attachment_data = create(:attachment_data, attachable: build(:draft_publication, id: 1))
    replacement_attachment_data = create(:attachment_data, to_replace_id: attachment_data.id, attachable: build(:draft_publication, id: 1))

    replacement_attachment_data.handle_to_replace_id

    assert_equal attachment_data.reload.replaced_by_id, replacement_attachment_data.id
  end

  test "replacement_asset_for returns asset of replacement" do
    attachment_data = create(:attachment_data, attachable: build(:draft_publication, id: 1))
    replacement_attachment_data = create(:attachment_data, to_replace_id: attachment_data.id, attachable: build(:draft_publication, id: 1))

    attachment_data.replace_with!(replacement_attachment_data)

    asset = attachment_data.assets.first
    replacement_asset = replacement_attachment_data.assets.first

    assert_equal attachment_data.replacement_asset_for(asset).id, replacement_asset.id
  end
end
