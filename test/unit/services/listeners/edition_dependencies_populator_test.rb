require "test_helper"

class ServiceListeners::EditionDependenciesPopulatorTest < ActiveSupport::TestCase

  [:publisher, :force_publisher].each do |service_name|
    test "Whitehall.edition_services.#{service_name} populates edition's dependencies" do
      contact, speech = create(:contact), create(:speech)
      news_article = create(:submitted_news_article, body: "For more information, get in touch at:
        [Contact:#{contact.id}] or read our [official statement](/government/admin/speeches/#{speech.id})", major_change_published_at: Time.zone.now)

      stub_panopticon_registration(news_article)

      assert Whitehall.edition_services.send(service_name, news_article).perform!
      assert_equal [contact], news_article.depended_upon_contacts
      assert_equal [speech], news_article.depended_upon_editions
    end
  end
end
