require 'test_helper'

class StatisticalReleaseAnnouncementFilterHelperTest < ActionView::TestCase
  test "#organisation_options_for_release_announcement_filter renders select options for all organisations with an associated release announcement in alphabetical order selecting passed in organisation" do
    org_1, org_2, org_3 = create(:organisation, name: "B org"), create(:organisation, name: "C org"), create(:organisation, name: "A org")

    create :statistical_release_announcement, organisation: org_2
    create :statistical_release_announcement, organisation: org_3

    rendered = Nokogiri::HTML::DocumentFragment.parse(organisation_options_for_release_announcement_filter(org_3.slug))
    options = rendered.css("option")

    assert_equal ["All departments", org_3.name, org_2.name], options.map(&:text)
    assert_equal ["", org_3.slug, org_2.slug], options.map {|option| option[:value]}
    assert options[1][:selected]
  end

  test "#topic_options_for_release_announcement_filter renders select options for all topics with an associated release announcement in alphabetical order selecting passed in topic" do
    topic_1, topic_2, topic_3 = create(:topic, name: "B topic"), create(:topic, name: "C topic"), create(:topic, name: "A topic")

    create :statistical_release_announcement, topic: topic_2
    create :statistical_release_announcement, topic: topic_3

    rendered = Nokogiri::HTML::DocumentFragment.parse(topic_options_for_release_announcement_filter(topic_3.slug))
    options = rendered.css("option")

    assert_equal ["All topics", topic_3.name, topic_2.name], options.map(&:text)
    assert_equal ["", topic_3.slug, topic_2.slug], options.map {|option| option[:value]}
    assert options[1][:selected]
  end
end
