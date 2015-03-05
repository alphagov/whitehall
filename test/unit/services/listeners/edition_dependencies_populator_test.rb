require "test_helper"

class ServiceListeners::EditionDependenciesPopulatorTest < ActiveSupport::TestCase

  [:publisher, :force_publisher].each do |service_name|
    test "Whitehall.edition_services.#{service_name} populates edition's dependencies" do
      contacts = create_list(:contact, 2)
      news_article = create(:submitted_news_article, body: "For more information, get in touch at:
        [Contact:#{contacts[0].id}] or [Contact:#{contacts[1].id}]", major_change_published_at: Time.zone.now)

      stub_panopticon_registration(news_article)

      assert Whitehall.edition_services.send(service_name, news_article).perform!
      assert_same_elements contacts, news_article.contact_dependencies
    end
  end

end
