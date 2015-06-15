require 'test_helper'

module DataHygiene
  class EditionUnwithdrawerTest < ActiveSupport::TestCase
    setup do
      @edition = FactoryGirl.create(:published_edition, state: 'withdrawn')
      @user = FactoryGirl.create(:user, id: 406)
    end

    test "initialize with a non-existent edition id errors" do
      assert_raises ActiveRecord::RecordNotFound do
        EditionUnwithdrawer.new(123)
      end
    end

    test "initialize with an existing edition id finds the edition" do
      assert_equal @edition, EditionUnwithdrawer.new(@edition.id).edition
    end

    test "initialize finds the correct user for unarchiving" do
      assert_equal @user, EditionUnwithdrawer.new(@edition.id).user
    end

    test "initialize raises an error unless the edition is withdrawn" do
      @edition.update_attribute(:state, "published")
      assert_raises RuntimeError do
        EditionUnwithdrawer.new(@edition.id)
      end
    end

    test "unwithdraw performs steps in a transaction" do
      EditionForcePublisher.any_instance.stubs(:perform!).raises("Something bad happened here.")

      assert_raises RuntimeError do
        EditionUnwithdrawer.new(@edition.id).unwithdraw!
      end
      @edition.reload

      assert_equal "withdrawn", @edition.state
    end

    test "unwithdraw updates the state of the original edition to superseded" do
      EditionUnwithdrawer.new(@edition.id).unwithdraw!
      @edition.reload
      assert_equal "superseded", @edition.state
    end

    test "unwithdraw publishes a draft of the withdrawn edition" do
      unwithdrawen_edition = EditionUnwithdrawer.new(@edition.id).unwithdraw!
      assert unwithdrawen_edition.published?
      assert unwithdrawen_edition.minor_change
      assert_equal @edition.document, unwithdrawen_edition.document
      assert_equal @user, unwithdrawen_edition.editorial_remarks.first.author
      assert_equal "Unwithdrawn", unwithdrawen_edition.editorial_remarks.first.body
    end

    test "unwithdraw handles legacy withdrawn editions" do
      edition = FactoryGirl.create(:published_edition, state: 'withdrawn')
      unwithdrawen_edition = EditionUnwithdrawer.new(edition.id).unwithdraw!
      assert unwithdrawen_edition.published?
      assert unwithdrawen_edition.minor_change
      assert_equal edition.document, unwithdrawen_edition.document
      assert_equal @user, unwithdrawen_edition.editorial_remarks.first.author
      assert_equal "Unwithdrawn", unwithdrawen_edition.editorial_remarks.first.body
    end
  end
end
