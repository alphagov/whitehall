require "test_helper"

class FilterHelperTest < ActionView::TestCase
  include TaxonomyHelper

  test "#organisation_options_for_statistics_announcement_filter renders select options for all organisations with an associated release announcement in alphabetical order selecting passed in organisation" do
    _org1 = create(:organisation, name: "B org")
    org2 = create(:organisation, name: "C org")
    org3 = create(:organisation, name: "A org")

    create :statistics_announcement, organisation_ids: [org2.id]
    create :statistics_announcement, organisation_ids: [org3.id]

    rendered = Nokogiri::HTML::DocumentFragment.parse(organisation_options_for_statistics_announcement_filter(org3.slug))
    options = rendered.css("option")
    option_values = options.map { |option| option[:value] }

    assert_equal ["All departments", org3.name, org2.name], options.map(&:text)
    assert_equal ["", org3.slug, org2.slug], option_values
    assert options[1][:selected]
  end

  test "#topic_options_for_statistics_announcement_filter renders select options for all topics with an associated release announcement in alphabetical order selecting passed in topic" do
    topic_b = build(:taxon_hash, content_id: "b-content-id", title: "B")
    topic_c = build(:taxon_hash, content_id: "c-content-id", title: "C")
    topic_z = build(:taxon_hash, content_id: "z-content-id", title: "Z")

    redis_cache_has_taxons([topic_b, topic_c, topic_z])

    create :statistics_announcement
    create :statistics_announcement

    rendered = Nokogiri::HTML::DocumentFragment.parse(topic_options_for_statistics_announcement_filter(topic_b["content_id"]))
    options = rendered.css("option")
    option_values = options.map { |option| option[:value] }

    assert_equal ["All topics", topic_b["title"], topic_c["title"], topic_z["title"]], options.map(&:text)
    assert_equal ["", topic_b["content_id"], topic_c["content_id"], topic_z["content_id"]], option_values
    assert options[1][:selected]
  end
end
