require 'test_helper'

class FilterRoutesHelperTest < ActionView::TestCase
  test 'uses the organisation to generate the route to publications filter' do
    organisation = create(:organisation)
    assert_equal publications_path(departments: [organisation.slug]), publications_filter_path(organisation)
  end

  test 'uses the organisation to generate the route to announcment filter' do
    organisation = create(:organisation)
    assert_equal announcements_path(departments: [organisation.slug]), announcements_filter_path(organisation)
  end

  test 'uses the organisation to generate the route to specialist filter' do
    organisation = create(:organisation)
    assert_equal specialist_guides_path(departments: [organisation.slug]), specialist_guides_filter_path(organisation)
  end

  test 'uses the topic to generate the route to specialist filter' do
    topic = create(:topic)
    assert_equal specialist_guides_path(topics: [topic.slug]), specialist_guides_filter_path(topic)
  end

end
