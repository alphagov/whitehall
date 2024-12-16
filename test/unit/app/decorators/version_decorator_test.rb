require "test_helper"

class VersionDecoratorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:user) { build(:user) }
  let(:edition) { build(:edition) }
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
end
