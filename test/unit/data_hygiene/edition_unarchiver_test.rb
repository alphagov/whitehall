require 'test_helper'

module DataHygiene
  class EditionUnarchiverTest < ActiveSupport::TestCase
    setup do
      @edition = FactoryGirl.create(:published_edition, state: 'archived')
      @user = FactoryGirl.create(:user, id: 406)
    end

    test "initialize with a non-existent edition id errors" do
      assert_raises ActiveRecord::RecordNotFound do
        EditionUnarchiver.new(123)
      end
    end

    test "initialize with an existing edition id finds the edition" do
      assert_equal @edition, EditionUnarchiver.new(@edition.id).edition
    end

    test "initialize finds the correct user for unarchiving" do
      assert_equal @user, EditionUnarchiver.new(@edition.id).user
    end

    test "initialize raises an error unless the edition is archived" do
      @edition.update_attribute(:state, "published")
      assert_raises RuntimeError do
        EditionUnarchiver.new(@edition.id)
      end
    end

    test "unarchive performs steps in a transaction" do
      EditionForcePublisher.any_instance.stubs(:perform!).raises("Something bad happened here.")

      assert_raises RuntimeError do
        EditionUnarchiver.new(@edition.id).unarchive
      end
      @edition.reload

      assert_equal "archived", @edition.state
    end

    test "unarchive updates the state of the original edition to superceded" do
      EditionUnarchiver.new(@edition.id).unarchive
      @edition.reload
      assert_equal "superseded", @edition.state
    end

    test "unarchive publishes a draft of the archived edition" do
      unarchived = EditionUnarchiver.new(@edition.id).unarchive
      assert unarchived.published?
      assert unarchived.minor_change
      assert_equal @edition.document, unarchived.document
      assert_equal @user, unarchived.editorial_remarks.first.author
      assert_equal "Unarchived", unarchived.editorial_remarks.first.body
    end
  end
end
