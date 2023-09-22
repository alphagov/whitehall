require "test_helper"

class ServiceListeners::EditionDependenciesTest < ActiveSupport::TestCase
  ["publish", "force publish"].each do |transition|
    service_name = "#{transition.parameterize.underscore}er"

    setup do
      stub_any_publishing_api_call
    end

    test "#{transition}ing an edition populates its dependencies" do
      contact = create(:contact)
      speech = create(:speech)
      news_article = create(
        :submitted_news_article,
        body: "For more information, get in touch at:
        [Contact:#{contact.id}] or read our [official statement](/government/admin/speeches/#{speech.id})",
        major_change_published_at: Time.zone.now,
      )

      assert Whitehall.edition_services.send(service_name, news_article).perform!
      assert_equal [contact], news_article.depended_upon_contacts
      assert_equal [speech], news_article.depended_upon_editions
    end

    test "#{transition}ing a depended-upon edition republishes the dependent edition" do
      Sidekiq::Testing.inline! do
        dependable_speech, dependent_article = create_article_dependent_on_speech

        expect_publishing(dependable_speech)
        expect_republishing(dependent_article)

        dependable_speech.major_change_published_at = Time.zone.now
        assert Whitehall.edition_services.send(service_name, dependable_speech).perform!
      end
    end

    test "#{transition}ing a depended-upon edition's subsequent edition doesn't republish the dependent edition" do
      Sidekiq::Testing.inline! do
        dependable_speech, dependent_article = create_article_dependent_on_speech

        dependable_speech.major_change_published_at = Time.zone.now
        assert Whitehall.edition_services.send(service_name, dependable_speech).perform!

        subsequent_edition_of_dependable_speech = dependable_speech.create_draft(create(:departmental_editor))
        subsequent_edition_of_dependable_speech.change_note = "change-note"
        subsequent_edition_of_dependable_speech.submit!

        expect_publishing(subsequent_edition_of_dependable_speech)
        expect_no_republishing(dependent_article)

        assert Whitehall.edition_services.send(service_name, subsequent_edition_of_dependable_speech).perform!
      end
    end
  end

  def create_article_dependent_on_speech
    dependable_speech = create(:submitted_speech)
    dependent_article = create(
      :published_news_article,
      major_change_published_at: Time.zone.now,
      body: "Read our [official statement](/government/admin/speeches/#{dependable_speech.id})",
    )
    dependent_article.depended_upon_editions << dependable_speech

    [dependable_speech, dependent_article]
  end
end
