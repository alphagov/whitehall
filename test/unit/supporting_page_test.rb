require "test_helper"

class SupportingPageTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :title, :body

  test "should be invalid without a title" do
    supporting_page = build(:supporting_page, title: nil)
    refute supporting_page.valid?
  end

  test "should be invalid without a body" do
    supporting_page = build(:supporting_page, body: nil)
    refute supporting_page.valid?
  end

  test "should be invalid without a policy" do
    supporting_page = build(:supporting_page)
    supporting_page.related_policy_ids = []
    refute supporting_page.valid?
  end

  test "related policies get updated change notes when supporting page is published" do
    skip
  end

  test "alerts sent for related policies when supporting page is published" do
    skip
  end

  test "should return search index data suitable for Rummageable" do
    skip
  end

  test "should return search index data for all supporting pages on published policies" do
    skip

    policy = create(:published_policy)
    draft_policy = create(:draft_policy)
    policy_slug = policy.document.slug
    create(:supporting_page, related_policies: [policy], title: 'Love all the people', body: 'Thoughts on love and smoking.')
    create(:supporting_page, related_policies: [policy], title: 'Dangerous', body: 'I love my job.')
    create(:supporting_page, related_policies: [policy], title: 'Relentless', body: 'Rockers against drugs suck.')
    create(:supporting_page, related_policies: [policy], title: 'Arizona Bay', body: 'Marketing and advertising.')
    create(:supporting_page, related_policies: [draft_policy], title: 'Rant in E-Minor', body: 'I\'m talking to the women here.')

    results = SupportingPage.search_index.to_a

    assert_equal 4, results.length
    assert_equal({'title' => 'Love all the people',
                  'link' => "/government/policies/#{policy_slug}/supporting-pages/love-all-the-people",
                  'indexable_content' => 'Thoughts on love and smoking.',
                  'format' => 'supporting_page',
                  'description' => ''}, results[0])
    assert_equal({'title' => 'Dangerous',
                  'link' => "/government/policies/#{policy_slug}/supporting-pages/dangerous",
                  'indexable_content' => 'I love my job.',
                  'format' => 'supporting_page',
                  'description' => ''}, results[1])
    assert_equal({'title' => 'Relentless',
                  'link' => "/government/policies/#{policy_slug}/supporting-pages/relentless",
                  'indexable_content' => 'Rockers against drugs suck.',
                  'format' => 'supporting_page',
                  'description' => ''}, results[2])
    assert_equal({'title' => 'Arizona Bay',
                  'link' => "/government/policies/#{policy_slug}/supporting-pages/arizona-bay",
                  'indexable_content' => 'Marketing and advertising.',
                  'format' => 'supporting_page',
                  'description' => ''}, results[3])
  end

  test "should allow inline attachments" do
    assert build(:supporting_page).allows_inline_attachments?
  end
end
