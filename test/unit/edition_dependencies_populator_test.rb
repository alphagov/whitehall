require "test_helper"

class EditionDependenciesPopulatorTest < ActiveSupport::TestCase
  test "populates contacts extracted from dependant editions' govspeak" do
    contacts = create_list(:contact, 2)
    news_article = create(:news_article, body: "For more information, get in touch at:
      [Contact:#{contacts[0].id}] or [Contact:#{contacts[1].id}]")

    EditionDependenciesPopulator.new(news_article).populate!

    assert_equal contacts, news_article.dependencies.contacts.map(&:dependable)
  end

  test "ignores duplicate dependencies" do
    contact = create(:contact)
    news_article = create(:news_article, body: "For more information, get in touch at: [Contact:#{contact.id}]")
    EditionDependency.create!(dependant: news_article, dependable: contact)

    assert_nothing_raised { EditionDependenciesPopulator.new(news_article).populate! }
    # would otherwise raise ActiveRecord::RecordNotUnique
  end
end
