require "test_helper"

module PublishingApi
  class BaseItemPresenterTest < ActiveSupport::TestCase
    extend Minitest::Spec::DSL

    describe ".base_attributes" do
      let(:presenter) { PublishingApi::BaseItemPresenter.new(stubbed_item, update_type: "major", locale: "fr") }
      let(:expected_hash) do
        {
          title: stubbed_item.title,
          locale: "fr",
          publishing_app: Whitehall::PublishingApp::WHITEHALL,
          redirects: [],
          update_type: "major",
        }
      end

      context "when the item does not respond to last_author" do
        let(:stubbed_item) { stub(title: "A title") }
        let(:last_edited_by_editor_id) { nil }

        it "returns the base set of attributes needed by all documents sent to the publishing API" do
          assert_equal presenter.base_attributes, expected_hash
        end
      end

      context "when the item responds to last_author" do
        let(:last_edited_by_editor_id) { SecureRandom.uuid }
        let(:last_author) { stub(uid: last_edited_by_editor_id) }
        let(:stubbed_item) { stub(title: "A title", last_author:) }
        let(:updated_expected_hash) do
          expected_hash.merge(
            last_edited_by_editor_id:,
          )
        end

        it "returns the base set of attributes needed by all documents sent to the publishing API" do
          assert_equal presenter.base_attributes, updated_expected_hash
        end
      end
    end
  end
end
