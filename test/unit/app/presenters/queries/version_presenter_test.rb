require "test_helper"

class Queries::VersionPresenterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:user) { build(:user) }
  let(:edition) { build(:edition) }
  let(:version) { build(:version, user:, item: edition) }
  let(:is_first_edition) { false }
  let(:previous_version) { build(:version, user:, item: edition) }

  let(:presenter) { Queries::VersionPresenter.new(version, is_first_edition:, previous_version:) }

  describe ".model_name" do
    it "returns the model name" do
      assert_equal Queries::VersionPresenter.model_name, ActiveModel::Name.new(Version, nil)
    end
  end

  describe "#actor" do
    it "returns the version's user" do
      assert_equal presenter.actor, version.user
    end
  end

  describe "#action" do
    context "when the event is `create`" do
      let(:version) { build(:version, user:, item: edition, event: "create") }

      it "returns `editioned`" do
        assert_equal presenter.action, "editioned"
      end

      context "and the edition is the first edition" do
        let(:is_first_edition) { true }

        it "returns `created`" do
          assert_equal presenter.action, "created"
        end
      end
    end

    context "when the state has not changed" do
      let(:version) { build(:version, user:, item: edition, state: "some_state") }
      let(:previous_version) { build(:version, user:, item: edition, state: "some_state") }

      it "returns `updated`" do
        assert_equal presenter.action, "updated"
      end
    end

    context "when the state has changed" do
      let(:version) { build(:version, user:, item: edition, state: "state2") }
      let(:previous_version) { build(:version, user:, item: edition, state: "state1") }

      it "returns the version's state" do
        assert_equal presenter.action, version.state
      end
    end

    context "when previous_version is not preloaded" do
      let(:previous_version) { nil }

      it "loads the previous version" do
        loaded_version = build(:version, user:, item: edition)
        version.expects(:previous).returns(loaded_version)

        presenter.action
      end
    end
  end
end
