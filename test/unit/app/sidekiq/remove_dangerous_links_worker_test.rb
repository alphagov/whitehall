require "test_helper"

class RemoveDangerousLinksWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  before do
    @dangerous_body = <<~GOVSPEAK
      [dangerous link](http://www.example.com)
      <a href="http://www.example.com">dangerous link again</a>
      [another way of linking to dangerous link][danger]

      [danger]: http://www.example.com
    GOVSPEAK
  end

  describe "#perform" do
    before do
      User.create!(name: "Scheduled Publishing Robot") unless User.find_by(name: "Scheduled Publishing Robot")
    end

    describe "the happy path" do
      it "creates and publishes a new edition" do
        published_edition = create(:publication, :published, body: @dangerous_body)
        create_danger_link_check_report(published_edition)
        RemoveDangerousLinksWorker.new.perform(published_edition.id)

        assert_not_equal(published_edition.id, published_edition.document.live_edition.id)
        assert_equal(User.find_by(name: "Scheduled Publishing Robot").id, published_edition.versions.last.whodunnit.to_i)
      end

      it "removes dangerous links from the body of the new edition" do
        sterilised_body = <<~GOVSPEAK
          [dangerous link](#link-removed)
          <a href="#link-removed">dangerous link again</a>
          [another way of linking to dangerous link][danger]

          [danger]: #link-removed
        GOVSPEAK

        published_edition = create(:publication, :published, body: @dangerous_body)
        create_danger_link_check_report(published_edition)
        RemoveDangerousLinksWorker.new.perform(published_edition.id)

        assert_equal(sterilised_body, published_edition.document.live_edition.body)
      end

      it "saves an internal changenote against the new edition" do
        published_edition = create(:publication, :published, body: @dangerous_body)
        create_danger_link_check_report(published_edition)
        RemoveDangerousLinksWorker.new.perform(published_edition.id)

        assert_equal(
          "Dangerous links automatically removed: http://www.example.com",
          published_edition.document.latest_edition.editorial_remarks.last.body,
        )
      end
    end

    describe "content body is already free of dangerous links (which can happen in a race condition of link check report calls)" do
      it "doesn't create a new draft edition, and just silently succeeds" do
        published_edition = create(:publication, :published, body: "harmless body")
        create_danger_link_check_report(published_edition)

        worker = RemoveDangerousLinksWorker.new
        worker.expects(:create_sanitized_edition_and_publish_it!).never

        worker.perform(published_edition.id)
      end
    end

    describe "error handling" do
      it "raises an exception if the passed edition is not 'published'" do
        draft_edition = create(:publication, :draft)
        create_danger_link_check_report(draft_edition)

        error = assert_raises(ArgumentError) do
          RemoveDangerousLinksWorker.new.perform(draft_edition.id)
        end
        assert_equal "draft edition with ID #{draft_edition.id} passed to RemoveDangerousLinksWorker: expecting 'published'", error.message
      end

      it "does nothing if the edition is published but there is a newer draft (we don't want to risk overwriting with our changes)" do
        published_edition = create(:publication, :published)
        create_danger_link_check_report(published_edition)
        published_edition.create_draft(create(:user))

        error = assert_raises(ArgumentError) do
          RemoveDangerousLinksWorker.new.perform(published_edition.id)
        end
        assert_equal "Published edition with ID #{published_edition.id} passed to RemoveDangerousLinksWorker but it already has a draft. Aborting to avoid overwriting.", error.message
      end

      it "does nothing if there are no dangerous links" do
        published_edition = create(:publication, :published)
        create_happy_link_check_report(published_edition)

        worker = RemoveDangerousLinksWorker.new
        worker.expects(:remove_danger_links).never

        worker.perform(published_edition.id)
      end
    end
  end

private

  def create_danger_link_check_report(edition)
    create(
      :link_checker_api_report_completed,
      edition: edition,
      links: [
        create(:link_checker_api_report_link, :danger, uri: "http://www.example.com"),
      ],
    )
  end

  def create_happy_link_check_report(edition)
    create(
      :link_checker_api_report_completed,
      edition: edition,
      links: [],
    )
  end
end
