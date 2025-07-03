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

      it "logs but avoids processing cases where the passed Edition and its HTML attachments would be unchanged by the find-and-replace" do
        published_edition = create(:published_edition, body: "something safe")
        params = valid_params.merge("edition_id" => published_edition.id)

        expected_msg = "Skipping: Edition #{published_edition.id}. Neither it nor its HTML attachments need changing."
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

        it "performs a find-and-replace on the bodies of the Edition's HTML Attachments, but keeps the Edition as a draft" do
          draft_edition = create(:draft_edition, body: "lorem ipsum")
          attachment = create(:html_attachment, attachable: draft_edition)
          attachment.govspeak_content.update!(body: "foo")
          params = {
            "edition_id" => draft_edition.id,
            "replacements" => [{ "find" => "foo", "replace" => "bar" }],
          }

          worker = FindAndReplaceWorker.new
          worker.expects(:log).with("Success: performed find-and-replace on edition #{draft_edition.id} and its HTML attachments (#{attachment.slug}) and saved the draft.")
          worker.perform(params)

          assert_equal "draft", draft_edition.reload.state
          assert_equal draft_edition.reload.body, "lorem ipsum"
          assert_equal draft_edition.reload.html_attachments.last.body, "bar"
        end

        it "performs a find-and-replace on the edition body, but keeps it as a draft" do
          scheduled_edition = create(:scheduled_edition, body: "foo lorem ipsum")
          params = {
            "edition_id" => scheduled_edition.id,
            "replacements" => [{ "find" => "foo", "replace" => "bar" }],
          }

          expected_msg = "Success: performed find-and-replace on edition #{scheduled_edition.id} and saved the draft."
          worker = FindAndReplaceWorker.new
          worker.expects(:log).with(expected_msg)
          worker.perform(params)

          assert_equal "scheduled", scheduled_edition.reload.state
          assert_includes scheduled_edition.reload.body, "bar"
          assert_not_includes scheduled_edition.reload.body, "foo"
        end

        it "performs a find-and-replace on the bodies of the Edition's HTML Attachments, but keeps the Edition as a draft" do
          force_scheduled_edition = create(:force_scheduled_edition, body: "lorem ipsum")
          attachment = create(:html_attachment, attachable: force_scheduled_edition)
          attachment.govspeak_content.update!(body: "foo")
          params = {
            "edition_id" => force_scheduled_edition.id,
            "replacements" => [{ "find" => "foo", "replace" => "bar" }],
          }

          worker = FindAndReplaceWorker.new
          worker.expects(:log).with("Success: performed find-and-replace on edition #{force_scheduled_edition.id} and its HTML attachments (#{attachment.slug}) and saved the draft.")
          worker.perform(params)

          assert_equal "scheduled", force_scheduled_edition.reload.state
          assert_equal force_scheduled_edition.reload.body, "lorem ipsum"
          assert_equal force_scheduled_edition.reload.html_attachments.last.body, "bar"
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
            expected_msg = /Success: performed find-and-replace on edition #{published_edition.id}, saving and publishing this as new edition \d+\./
            worker = FindAndReplaceWorker.new
            worker.expects(:log).with(regexp_matches(expected_msg))
            worker.perform(params)
          end

          latest = published_edition.document.reload.latest_edition
          assert_equal "published", latest.state
          assert_includes latest.body, "bar"
          assert_not_includes latest.body, "foo"
        end

        it "performs a find-and-replace on the bodies of the Edition's HTML Attachments, and publishes the Edition" do
          published_edition = create(:published_edition, body: "lorem ipsum")
          attachment = create(:html_attachment, attachable: published_edition)
          attachment.govspeak_content.update!(body: "foo")
          params = {
            "edition_id" => published_edition.id,
            "replacements" => [{ "find" => "foo", "replace" => "bar" }],
          }

          assert_difference(
            -> { Edition.where(document: published_edition.document).count },
            +1,
            "A new (draft) edition should be created and then published",
          ) do
            worker = FindAndReplaceWorker.new
            worker.expects(:log).with("Success: performed find-and-replace on edition #{published_edition.id} and its HTML attachments (#{attachment.slug}), saving and publishing this as new edition #{published_edition.id + 1}.")
            worker.perform(params)
          end

          latest = published_edition.document.reload.latest_edition
          assert_equal "published", latest.state
          assert_equal latest.body, "lorem ipsum"
          assert_equal latest.html_attachments.last.body, "bar"
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

        it "saves a custom internal changenote against the new edition, if provided" do
          published_edition = create(:published_edition, body: "foo")
          params            = valid_params.merge("edition_id" => published_edition.id, "changenote" => "Replaced foo with bar")
          FindAndReplaceWorker.new.perform(**params)

          assert_equal(
            "Replaced foo with bar",
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

    describe "logging with custom prefix" do
      it "logs with custom prefix if provided" do
        edition = create(:draft_edition, body: "foo")
        params = valid_params.merge("log_prefix" => "[MyFindAndReplaceScript] ", "edition_id" => edition.id)

        log_io = StringIO.new
        custom_logger = Logger.new(log_io)
        Rails.stub(:logger, custom_logger) do
          FindAndReplaceWorker.new.perform(params)
        end

        assert_match "[MyFindAndReplaceScript] Success: performed find-and-replace on edition #{edition.id} and saved the draft.", log_io.string
      end
    end
  end
end
