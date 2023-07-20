require "test_helper"

class DocumentResluggerTest < ActiveSupport::TestCase
  setup do
    stub_any_publishing_api_call
    @user = create(:user)
    @document = create(:document, slug: "old-slug", document_type: "news_article")
    @published_edition = create(:edition, :published)
  end

  test "updates the slug to the new slug, updated the publishing API, reindexes the slug on search index and creates an EditorialRemark" do
    reslugger = DataHygiene::DocumentReslugger.new(@document, @published_edition, @user, "new-slug")

    Whitehall::SearchIndex.expects(:delete).with(@published_edition)
    PublishingApiDocumentRepublishingWorker.expects(:new).returns(worker = mock)
    worker.expects(:perform).with(@document.id)
    Whitehall::SearchIndex.expects(:add).with(@published_edition)

    reslugger.run!

    assert_equal "new-slug", @document.slug
    assert_equal @published_edition.editorial_remarks.count, 1
    assert_equal @published_edition.editorial_remarks.first.author_id, @user.id
    assert_equal @published_edition.editorial_remarks.first.body, "Updated document slug to new-slug"
  end

  test "returns false and the adds an error to the document when new_slug is blank" do
    reslugger = DataHygiene::DocumentReslugger.new(@document, @published_edition, @user, "")
    assert_equal false, reslugger.run!
    assert_equal @document.errors.full_messages, ["Slug is blank"]
  end

  test "returns false and the adds an error when the new slug is present on an another document of the same type" do
    create(:document, slug: "new-slug", document_type: "news_article")

    reslugger = DataHygiene::DocumentReslugger.new(@document, @published_edition, @user, "new-slug")
    assert_equal false, reslugger.run!
    assert_equal @document.errors.full_messages, ["Slug must be unique"]
  end

  test "updates the slug when the new slug is present on an another document of a different type" do
    create(:document, slug: "new-slug", document_type: "publication")

    reslugger = DataHygiene::DocumentReslugger.new(@document, @published_edition, @user, "new-slug")
    reslugger.run!

    assert_equal "new-slug", @document.slug
  end

  test "returns false and the adds an error to the document when new_slug starts with a slash" do
    reslugger = DataHygiene::DocumentReslugger.new(@document, @published_edition, @user, "/invalid slug")
    assert_equal false, reslugger.run!
    assert_equal @document.errors.full_messages, ["Slug should not start with a slash"]
  end
end
