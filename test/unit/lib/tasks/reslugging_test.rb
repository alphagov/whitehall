require "test_helper"
require "rake"

class ResluggingTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown do
    task.reenable
    Sidekiq::Job.clear_all
  end

  describe "for world location" do
    let(:task) { Rake::Task["reslug:world_location"] }

    test "it should reslug" do
      world_location_news = build(:world_location_news, content_id: SecureRandom.uuid)
      world_location = create(:world_location, slug: "old-name", world_location_news:)
      task.invoke("old-name", "new-name")
      Rake.application.invoke_task "reslug:world_location[old-name,new-name]"
      assert_equal "new-name", world_location.reload.slug
    end
  end

  describe "for HTML attachments" do
    let(:task) { Rake::Task["reslug:html_attachment"] }
    let(:html_attachment_title) { "HTML Attachment" }
    let(:new_html_attachment_title) { "New #{html_attachment_title}" }
    let(:html_attachment_slug) { html_attachment_title.to_slug.normalize.to_s }
    let(:new_html_attachment_slug) { new_html_attachment_title.to_slug.normalize.to_s }

    it "reslugs if attached to a published edition" do
      published_edition = create(:published_edition)

      existing_html_attachment = create(:html_attachment, title: html_attachment_title, body: "Some text on a published edition", attachable: published_edition)

      # if attached to a published edition the
      # attachment shouldn't be safely resluggable
      existing_html_attachment.update!(safely_resluggable: false)

      existing_html_attachment.update!(title: new_html_attachment_title)

      task.invoke(published_edition.slug, existing_html_attachment.slug)

      # attachment slug should have changed
      assert_equal existing_html_attachment.reload.slug, new_html_attachment_slug
      # attachment should not be resluggable after task
      assert_equal existing_html_attachment.reload.safely_resluggable, false
    end

    it "reslugs if deleted attached HTML attachment with same slug" do
      published_edition = create(:published_edition)
      published_edition.document

      deleted_html_attachment = create(:html_attachment, title: html_attachment_title, body: "Some text on a published edition", attachable: published_edition)

      deleted_html_attachment.delete

      existing_html_attachment = create(:html_attachment, title: html_attachment_title, body: "Some text on a published edition", attachable: published_edition)

      task.invoke(published_edition.slug, existing_html_attachment.slug)

      existing_html_attachment = existing_html_attachment.reload
      new_edition = published_edition.document.editions.published.last

      deleted_html_attachment_from_edition = new_edition.attachments.unscoped.deleted.where(slug: html_attachment_slug)

      # there should be no deleted attachment with the slug
      assert_empty deleted_html_attachment_from_edition
      # attachment slug should have changed
      assert_equal existing_html_attachment.slug, html_attachment_slug
    end

    it "does not reslug if undeleted attached HTML attachment with same slug" do
      published_edition = create(:published_edition)
      published_edition.document

      create(:html_attachment, title: html_attachment_title, body: "Some text on a published edition", attachable: published_edition)

      existing_html_attachment = create(:html_attachment, title: html_attachment_title, body: "Some text on a published edition", attachable: published_edition)

      assert_raises(StandardError, match: "Attachment with slug '#{html_attachment_slug}' already exists and has been not deleted. Delete this attachment first.") do
        task.invoke(published_edition.slug, existing_html_attachment.slug)
      end
    end
  end
end
