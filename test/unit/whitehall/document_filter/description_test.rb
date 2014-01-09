require 'test_helper'

class Whitehall::DocumentFilter::DescriptionTest < ActiveSupport::TestCase

  test 'returns a blank string if given no URL' do
    assert_equal '', Whitehall::DocumentFilter::Description.new('').text
    assert_equal '', Whitehall::DocumentFilter::Description.new(nil).text
  end

  test 'builds a human-readable description of a document filter using the filter drop-down texts' do
    publication_feed = "https://example.com/government/publications.atom?&departments%5B%5D=all&keywords=&official_document_status=all&publication_filter_option=closed-consultations&topics%5B%5D=all"
    description = Whitehall::DocumentFilter::Description.new(publication_feed)

    assert_match /closed consultations/, description.text
    assert_match /all departments/, description.text
    assert_match /all topics/, description.text
  end

  test 'properly describes department filters' do
    create(:ministerial_department, :with_published_edition, name: "Department of Health", slug: "department-of-health")
    publication_feed = 'http://example.com/government/publications.atom?&departments%5B%5D=department-of-health&keywords=&official_document_status=command_and_act_papers&publication_filter_option=all&topics%5B%5D=all'
    description = Whitehall::DocumentFilter::Description.new(publication_feed)

    assert_match /Department of Health/, description.text
  end

  test 'describes policy filters' do
    create(:published_policy, title: "Supporting vibrant and sustainable arts and culture")
    policy_feed = "http://example.com/government/policies/supporting-vibrant-and-sustainable-arts-and-culture/activity.atom"
    description = Whitehall::DocumentFilter::Description.new(policy_feed)
    assert_match /sustainable arts/, description.text
  end

  test 'describes role filters' do
    create(:role, name: 'Prime Minister', slug: 'prime-minister')
    policy_feed = "http://example.com/government/ministers/prime-minister.atom"
    description = Whitehall::DocumentFilter::Description.new(policy_feed)
    assert_match /Prime Minister/, description.text
  end

  test 'describes people filters' do
    create(:person, forename: 'Francis', surname: 'Maude', slug: 'francis-maude')
    policy_feed = "http://example.com/government/people/francis-maude.atom"
    description = Whitehall::DocumentFilter::Description.new(policy_feed)
    assert_match /Francis Maude/, description.text
  end

end
