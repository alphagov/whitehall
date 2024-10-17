require "test_helper"

module PublishingApi
  module PayloadBuilder
    class LastEditedByEditorIdTest < ActiveSupport::TestCase
      extend Minitest::Spec::DSL

      it "returns the UUID of the last author if present" do
        last_author = stub(uid: SecureRandom.uuid)
        item = stub(last_author:)

        assert_equal(
          { last_edited_by_editor_id: last_author.uid },
          LastEditedByEditorId.for(item),
        )
      end

      it "returns an empty hash if a last author is not present" do
        item = stub(last_author: nil)

        assert_equal(
          {},
          LastEditedByEditorId.for(item),
        )
      end

      it "returns an empty hash if the last author uid is nil" do
        last_author = stub(uid: nil)
        item = stub(last_author:)

        assert_equal(
          {},
          LastEditedByEditorId.for(item),
        )
      end

      it "returns an empty hash if the item does not respond to `last_author`" do
        item = stub
        item.stubs(:respond_to?).with(:last_author).returns(false)

        assert_equal(
          {},
          LastEditedByEditorId.for(item),
        )
      end
    end
  end
end
