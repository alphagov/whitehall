require "test_helper"

class ServiceListeners::EditionDependenciesTest < ActiveSupport::TestCase

  ['publish', 'force publish'].each do |transition|
    service_name = transition.parameterize.underscore + 'er'

    test "#{transition}ing an edition populates its dependencies" do
      contact, speech = create(:contact), create(:speech)
      news_article = create(:submitted_news_article, body: "For more information, get in touch at:
        [Contact:#{contact.id}] or read our [official statement](/government/admin/speeches/#{speech.id})", major_change_published_at: Time.zone.now)

      stub_panopticon_registration(news_article)

      assert Whitehall.edition_services.send(service_name, news_article).perform!
      assert_equal [contact], news_article.depended_upon_contacts
      assert_equal [speech], news_article.depended_upon_editions
    end

    test "#{transition}ing a depended-upon edition removes it as a dependency" do
      dependable_speech = create(:submitted_speech)
      dependent_article = create(:published_news_article, major_change_published_at: Time.zone.now,
        body: "Read our [official statement](/government/admin/speeches/#{dependable_speech.id})")
      dependent_article.depended_upon_editions << dependable_speech

      stub_panopticon_registration(dependable_speech)
      dependable_speech.major_change_published_at = Time.zone.now
      assert Whitehall.edition_services.send(service_name, dependable_speech).perform!

      assert_empty dependable_speech.dependent_editions.reload
    end

    test "#{transition}ing a depended-upon edition republishes the dependent edition" do
      dependable_speech = create(:submitted_speech)
      dependent_article = create(:published_news_article, major_change_published_at: Time.zone.now,
        body: "Read our [official statement](/government/admin/speeches/#{dependable_speech.id})")
      dependent_article.depended_upon_editions << dependable_speech

      expect_publishing(dependable_speech)
      expect_republishing(dependent_article)

      stub_panopticon_registration(dependable_speech)
      dependable_speech.major_change_published_at = Time.zone.now
      assert Whitehall.edition_services.send(service_name, dependable_speech).perform!
    end

    test "#{transition}ing a depended-upon edition's subsequent edition doesn't republish the dependent edition" do
      dependable_speech = create(:submitted_speech)
      dependent_article = create(:published_news_article, major_change_published_at: Time.zone.now,
        body: "Read our [official statement](/government/admin/speeches/#{dependable_speech.id})")
      dependent_article.depended_upon_editions << dependable_speech

      stub_panopticon_registration(dependable_speech)
      dependable_speech.major_change_published_at = Time.zone.now
      assert Whitehall.edition_services.send(service_name, dependable_speech).perform!

      subsequent_edition_of_dependable_speech = dependable_speech.create_draft(create(:departmental_editor))
      subsequent_edition_of_dependable_speech.change_note = "change-note"
      subsequent_edition_of_dependable_speech.submit!

      stub_panopticon_registration(subsequent_edition_of_dependable_speech)
      expect_publishing(subsequent_edition_of_dependable_speech)
      expect_no_republishing(dependent_article)

      assert Whitehall.edition_services.send(service_name, subsequent_edition_of_dependable_speech).perform!
    end
  end

  test "unpublishing destroys edition's dependencies" do
    edition = create(:published_news_article)
    edition.depended_upon_contacts << create(:contact)
    edition.depended_upon_editions << create(:speech)

    stub_panopticon_registration(edition)
    edition.unpublishing = create(:unpublishing)
    assert Whitehall.edition_services.unpublisher(edition).perform!

    assert_empty edition.depended_upon_contacts.reload
    assert_empty edition.depended_upon_editions.reload
  end

end
