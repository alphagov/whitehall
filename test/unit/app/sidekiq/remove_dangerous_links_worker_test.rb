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

        RemoveDangerousLinksWorker.new.perform(published_edition.id)

        latest_edition = published_edition.document.reload.latest_edition
        assert_equal published_edition.id, latest_edition.id
      end
    end

    describe "error handling" do
      it "logs if the passed edition is not 'published' or editable" do
        withdrawn_edition = create(:withdrawn_edition)
        create_danger_link_check_report(withdrawn_edition)

        assert_logged "Aborting: Edition #{withdrawn_edition.id} was passed, but is in state 'withdrawn' and cannot be acted on." do
          RemoveDangerousLinksWorker.new.perform(withdrawn_edition.id)
        end
      end

      it "does nothing if there are no dangerous links" do
        published_edition = create(:publication, :published)
        create_happy_link_check_report(published_edition)

        FindAndReplaceWorker.expects(:new).never
        RemoveDangerousLinksWorker.new.perform(published_edition.id)
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

  def assert_logged(msg, &block)
    log_io = StringIO.new
    custom_logger = Logger.new(log_io)

    Rails.stub(:logger, custom_logger, &block)

    assert_match msg, log_io.string
  end
end
