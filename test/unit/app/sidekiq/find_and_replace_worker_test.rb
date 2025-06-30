require "test_helper"

class FindAndReplaceWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  before do
    User.find_or_create_by!(name: "Scheduled Publishing Robot")
  end

  let(:valid_params) do
    edition = create(:edition)
    {
      "edition_id" => edition.id,
      "replacements" => [
        { "find" => "foo", "replace" => "bar" },
      ],
    }
  end

  describe "#perform" do
    describe "raising exceptions if 'edition_id' or 'replacements' keyword args are missing or invalid" do
      it "raises an ArgumentError if edition_id is missing" do
        params = valid_params.except("edition_id")

        error = assert_raises(ArgumentError) { FindAndReplaceWorker.new.perform(params) }
        assert_equal "Error: missing keyword argument(s): edition_id", error.message
      end

      it "raises ActiveRecord::RecordNotFound if the Edition doesn't exist" do
        params = valid_params.merge("edition_id" => -1)

        error = assert_raises(ActiveRecord::RecordNotFound) { FindAndReplaceWorker.new.perform(params) }
        assert_match(/Couldn't find Edition with 'id'=-?1/, error.message)
      end

      it "raises an ArgumentError if replacements is missing" do
        params = valid_params.except("replacements")

        error = assert_raises(ArgumentError) { FindAndReplaceWorker.new.perform(params) }
        assert_equal "Error: missing keyword argument(s): replacements", error.message
      end

      it "raises an ArgumentError if replacements is not an array of hashes with 'find' and 'replace' keys" do
        invalid_inputs = [
          "not an array",
          [{ "find" => "foo" }],                  # missing "replace"
          [{ "replace" => "bar" }],               # missing "find"
          [{ "find" => "", "replace" => "bar" }], # blank find
          [{ "find" => "foo", "replace" => "" }], # blank replace
          [{}],                                   # empty hash
          [nil],                                  # nil entry
          [{ find: "foo", replace: "bar" }],      # symbol keys instead of string keys
        ]

        invalid_inputs.each do |bad_input|
          params = valid_params.merge("replacements" => bad_input)

          error = assert_raises(ArgumentError) { FindAndReplaceWorker.new.perform(params) }
          assert_match(/invalid 'replacements' argument/, error.message)
        end
      end
    end

    describe "skipping the find-and-replace logic if it is not applicable" do
      it "logs but avoids processing cases where the passed Edition is not the latest for its document" do
        published_edition = create(:published_edition)
        new_draft         = create(:draft_edition, document: published_edition.document)
        params            = valid_params.merge("edition_id" => published_edition.id)

        expected_msg = "Aborting: Edition #{published_edition.id} was passed, but there is a more recent Edition (#{new_draft.id})."
        worker = FindAndReplaceWorker.new
        worker.expects(:log).with(expected_msg)
        worker.perform(params)
      end

      it "logs but avoids processing cases where the passed Edition is 'unpublished' or 'withdrawn'" do
        unpublished_edition = create(:unpublished_edition)
        params              = valid_params.merge("edition_id" => unpublished_edition.id)

        expected_msg = "Aborting: Edition #{unpublished_edition.id} was passed, but is in state 'unpublished' and cannot be acted on."
        worker = FindAndReplaceWorker.new
        worker.expects(:log).with(expected_msg)
        worker.perform(params)
      end

      it "logs but avoids processing cases where the passed Edition would be unchanged by the find-and-replace" do
        published_edition = create(:published_edition, body: "something safe")
        params = valid_params.merge("edition_id" => published_edition.id)

        expected_msg = "Skipping: Edition #{published_edition.id}. Its body doesn't need changing."
        worker = FindAndReplaceWorker.new
        worker.expects(:log).with(expected_msg)
        worker.perform(params)
        assert_equal published_edition.reload.document.latest_edition.id, published_edition.id # no draft edition created
        assert_equal published_edition.reload.body, "something safe"
      end
    end

    describe "applying the find-and-replace logic" do
      describe "editing (but not publishing) the Edition (if it is in an editable state')" do
        it "performs a find-and-replace on the edition body, but keeps it as a draft" do
          draft_edition = create(:draft_edition, body: "foo lorem ipsum")
          params = {
            "edition_id" => draft_edition.id,
            "replacements" => [{ "find" => "foo", "replace" => "bar" }],
          }

          expected_msg = "Success: performed find-and-replace on edition #{draft_edition.id} and saved the draft."
          worker = FindAndReplaceWorker.new
          worker.expects(:log).with(expected_msg)
          worker.perform(params)

          assert_equal "draft", draft_edition.reload.state
          assert_includes draft_edition.reload.body, "bar"
          assert_not_includes draft_edition.reload.body, "foo"
        end

        it "logs the action against the automated user" do
          published_edition = create(:published_edition, body: "foo")
          params            = valid_params.merge("edition_id" => published_edition.id)
          FindAndReplaceWorker.new.perform(params)

          assert_equal(
            User.find_by(name: "Scheduled Publishing Robot").id,
            published_edition.versions.last.whodunnit.to_i,
          )
        end
      end

      describe "editing and publishing the Edition (if its state is 'published')" do
        it "creates a draft edition, performs a find-and-replace on the edition body, and publishes it" do
          published_edition = create(:published_edition, body: "foo lorem ipsum")
          params = {
            "edition_id" => published_edition.id,
            "replacements" => [{ "find" => "foo", "replace" => "bar" }],
          }

          assert_difference(
            -> { Edition.where(document: published_edition.document).count },
            +1,
            "A new (draft) edition should be created and then published",
          ) do
            expected_msg = /Success: performed find-and-replace on edition #{published_edition.id}, saving and publishing a new edition \d+\./
            worker = FindAndReplaceWorker.new
            worker.expects(:log).with(regexp_matches(expected_msg))
            worker.perform(params)
          end

          latest = published_edition.document.reload.latest_edition
          assert_equal "published", latest.state
          assert_includes latest.body, "bar"
          assert_not_includes latest.body, "foo"
        end

        it "saves an internal changenote against the new edition" do
          published_edition = create(:published_edition, body: "foo")
          params            = valid_params.merge("edition_id" => published_edition.id)
          FindAndReplaceWorker.new.perform(params)

          assert_equal(
            "Automatically republished content with some body changes",
            published_edition.document.latest_edition.editorial_remarks.last.body,
          )
        end

        it "logs the action against the automated user" do
          published_edition = create(:published_edition, body: "foo")
          params            = valid_params.merge("edition_id" => published_edition.id)
          FindAndReplaceWorker.new.perform(params)

          assert_equal(
            User.find_by(name: "Scheduled Publishing Robot").id,
            published_edition.versions.last.whodunnit.to_i,
          )
        end
      end
    end
  end
end
