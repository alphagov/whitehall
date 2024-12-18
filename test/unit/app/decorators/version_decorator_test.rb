require "test_helper"

class VersionDecoratorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:user) { build(:user) }
  let(:item_id) { 5 }
  let(:edition) { build(:edition, id: item_id) }
  let(:version) { build(:version, user:, item: edition) }
  let(:is_first_edition) { false }
  let(:previous_version) { build(:version, user:, item: edition) }

  let(:decorator) { VersionDecorator.new(version, is_first_edition:, previous_version:) }

  describe "#==" do
    it "is true if the class, ID and action are the same" do
      other_decorator = VersionDecorator.new(version, is_first_edition:, previous_version:)

      assert decorator == other_decorator
    end

    it "is not true if the class ID and action are different" do
      other_version = build(:version, user:, item: edition, id: 444)
      other_decorator = VersionDecorator.new(other_version, is_first_edition:, previous_version:)

      assert_not decorator == other_decorator
    end
  end

  describe "#actor" do
    it "returns the version's user" do
      assert_equal decorator.actor, version.user
    end
  end

  describe "#action" do
    context "when the event is `create`" do
      let(:version) { build(:version, user:, item: edition, event: "create") }

      it "returns `editioned`" do
        assert_equal decorator.action, "editioned"
      end

      context "and the edition is the first edition" do
        let(:is_first_edition) { true }

        it "returns `created`" do
          assert_equal decorator.action, "created"
        end
      end
    end

    context "when the state has not changed" do
      let(:version) { build(:version, user:, item: edition, state: "some_state") }
      let(:previous_version) { build(:version, user:, item: edition, state: "some_state") }

      it "returns `updated`" do
        assert_equal decorator.action, "updated"
      end
    end

    context "when the state has changed" do
      let(:version) { build(:version, user:, item: edition, state: "state2") }
      let(:previous_version) { build(:version, user:, item: edition, state: "state1") }

      it "returns the version's state" do
        assert_equal decorator.action, version.state
      end
    end

    context "when previous_version is not preloaded" do
      let(:previous_version) { nil }

      it "loads the previous version" do
        loaded_version = build(:version, user:, item: edition)
        version.expects(:previous).returns(loaded_version)

        decorator.action
      end
    end
  end

  describe "#is_for_newer_edition?" do
    it "returns true if the version's item_id is less than the edition's id" do
      edition_to_compare = build(:edition, id: item_id - 1)
      assert decorator.is_for_newer_edition?(edition_to_compare)
    end

    it "returns false if the version's item_id is greater than the edition's id" do
      edition_to_compare = build(:edition, id: item_id + 1)
      assert_not decorator.is_for_newer_edition?(edition_to_compare)
    end
  end

  describe "#is_for_current_edition?" do
    it "returns true if the version's item_id is equal to the edition's id" do
      edition_to_compare = build(:edition, id: item_id)
      assert decorator.is_for_current_edition?(edition_to_compare)
    end

    it "returns true if the version's item_id is not equal to the edition's id" do
      edition_to_compare = build(:edition, id: item_id + 1)
      assert_not decorator.is_for_current_edition?(edition_to_compare)
    end
  end

  describe "#is_for_older_edition?" do
    it "returns true if the version's item_id is greater than the edition's id" do
      edition_to_compare = build(:edition, id: item_id + 1)
      assert decorator.is_for_older_edition?(edition_to_compare)
    end

    it "returns false if the version's item_id is less than the edition's id" do
      edition_to_compare = build(:edition, id: item_id - 1)
      assert_not decorator.is_for_older_edition?(edition_to_compare)
    end
  end
end
