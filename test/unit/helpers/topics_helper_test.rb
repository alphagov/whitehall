require 'test_helper'

class TopicsHelperTest < ActionView::TestCase
  include TextAssertions

  test 'classification_contents_breakdown generates a sentence that starts with the number of published policies belonging to the classification' do
    t = create(:topic)

    assert_match(/0 published policies/, classification_contents_breakdown(t))

    create(:published_policy, topics: [t])
    assert_match(/1 published policy/, classification_contents_breakdown(t))

    create(:published_policy, topics: [t])
    assert_match(/2 published policies/, classification_contents_breakdown(t))
  end

  test 'classification_contents_breakdown generates a sentence that ends with the number of published detailed guides belonging to the classification' do
    t = create(:topic)

    assert_match(/0 published detailed guides/, classification_contents_breakdown(t))

    create(:published_detailed_guide, topics: [t])
    assert_match(/1 published detailed guide/, classification_contents_breakdown(t))

    create(:published_detailed_guide, topics: [t])
    assert_match(/2 published detailed guides/, classification_contents_breakdown(t))
  end

  test "#topic_links_sentence generates a sentence of topic links" do
    topics = 3.times.map { |n| create(:topic) }

    rendered = Nokogiri::HTML::DocumentFragment.parse(topic_links_sentence(topics))
    links = rendered.css('a')

    assert_equal topics.map(&:name),              links.map(&:text)
    assert_equal topics.map{ |t| topic_path(t) }, links.map{ |link| link[:href] }
    assert_string_includes "#{topics[0].name}, #{topics[1].name} and #{topics[2].name}", rendered.text
  end
end
