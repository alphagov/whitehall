require "test_helper"

class EditionDependenciesPopulatorTest < ActiveSupport::TestCase
  test "populates contacts extracted from dependent editions' govspeak" do
    contacts = create_list(:contact, 2)
    news_article = create(:news_article, body: "For more information, get in touch at:
      [Contact:#{contacts[0].id}] or [Contact:#{contacts[1].id}]")

    EditionDependenciesPopulator.new(news_article).populate!

    assert_same_elements contacts, news_article.contact_dependencies.reload
  end

  test "ignores duplicate dependencies" do
    contact = create(:contact)
    news_article = create(:news_article, body: "For more information, get in touch at: [Contact:#{contact.id}]")
    news_article.contact_dependencies << contact # dependency is populated already

    EditionDependenciesPopulator.new(news_article).populate!

    assert_same_elements [contact], news_article.contact_dependencies.reload
  end
end
