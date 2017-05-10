require "test_helper"

module ServiceListeners
  class EditionDependenciesPopulatorTest < ActiveSupport::TestCase
    test "populates contacts extracted from dependent editions' govspeak" do
      contacts = create_list(:contact, 2)
      news_article = create(:news_article, body: "For more information, get in touch at:
      [Contact:#{contacts[0].id}] or [Contact:#{contacts[1].id}]")

      EditionDependenciesPopulator.new(news_article).populate!

      assert_same_elements contacts, news_article.depended_upon_contacts.reload
    end

    test "populates editions extracted from dependent editions' govspeak" do
      speeches = create_list(:speech, 2)
      news_article = create(:news_article, body: "The Governor's speeches are available:
      - [London](/government/admin/speeches/#{speeches[0].id}), and
      - [Cambridge](/government/admin/speeches/#{speeches[1].id})")

      EditionDependenciesPopulator.new(news_article).populate!

      assert_same_elements speeches, news_article.depended_upon_editions.reload
    end

    test "doesn't try to re-create an existing contact dependency" do
      contact = create(:contact)
      news_article = create(:news_article, body: "For more information, get in touch at: [Contact:#{contact.id}]")
      news_article.depended_upon_contacts << contact # dependency is populated already

      EditionDependenciesPopulator.new(news_article).populate!

      assert_same_elements [contact], news_article.depended_upon_contacts.reload
    end

    test "doesn't try to re-create an existing edition dependency" do
      speech = create(:speech)
      news_article = create(:news_article, body: "Governor's new [speech](/government/admin/speeches/#{speech.id})")
      news_article.depended_upon_editions << speech # dependency is populated already

      EditionDependenciesPopulator.new(news_article).populate!

      assert_same_elements [speech], news_article.depended_upon_editions.reload
    end
  end
end
