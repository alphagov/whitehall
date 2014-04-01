require 'test_helper'

class TakePartPageTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :body

  test "invalid without a title" do
    refute build(:take_part_page, title: nil).valid?
  end

  test "limits title to a maximum of 255 characters" do
    page = build(:take_part_page)

    page.title = ('a' * 254)
    assert page.valid?

    page.title = ('a' * 255)
    assert page.valid?

    page.title = ('a' * 256)
    refute page.valid?
  end

  test "sets a slug from the organisation name" do
    page = create(:take_part_page, title: 'Show me the money')
    assert_equal 'show-me-the-money', page.slug
  end

  test "won't change the slug when the name is changed" do
    page = create(:take_part_page, title: 'Show me the money')
    page.update_attributes(title: 'You had me at hello')
    assert_equal 'show-me-the-money', page.slug
  end

  test "invalid without a body" do
    refute build(:take_part_page, body: nil).valid?
  end

  test "limits body to a maximum of (16.megabytes - 1) characters" do
    page = build(:take_part_page)

    page.body = ('a' * (16.megabytes - 2)) # 1 less
    assert page.valid?

    page.body += 'a' # exact
    assert page.valid?

    page.body += 'a' # 1 bigger
    refute page.valid?
  end

  test "invalid without a summary" do
    refute build(:take_part_page, summary: nil).valid?
  end

  test "limits summary to a maximum of 255 characters" do
    page = build(:take_part_page)

    page.summary = ('a' * 254)
    assert page.valid?

    page.summary = ('a' * 255)
    assert page.valid?

    page.summary = ('a' * 256)
    refute page.valid?
  end

  test "invalid without image on create" do
    refute build(:take_part_page, image: nil).valid?
  end

  test "invalid without image alt text on create" do
    refute build(:take_part_page, image_alt_text: nil).valid?
  end

  test "limits image alt text to a maximum of 255 characters" do
    page = build(:take_part_page)

    page.image_alt_text = ('a' * 254)
    assert page.valid?

    page.image_alt_text = ('a' * 255)
    assert page.valid?

    page.image_alt_text = ('a' * 256)
    refute page.valid?
  end

  test '.next_ordering returns us the next ordering available (1 more than the largest stored)' do
    TakePartPage.destroy_all
    assert_equal 1, TakePartPage.next_ordering

    create(:take_part_page, ordering: 20)
    assert_equal 21, TakePartPage.next_ordering

    create(:take_part_page, ordering: 10)
    assert_equal 21, TakePartPage.next_ordering

    create(:take_part_page, ordering: 99)
    assert_equal 100, TakePartPage.next_ordering
  end

  test 'if ordering is not supplied, it is set to the next_ordering when saving' do
    page_1 = create(:take_part_page, ordering: nil)
    assert_equal 1, page_1.ordering

    page_2 = create(:take_part_page, ordering: 20)
    assert_equal 20, page_2.ordering
  end

  test '.reorder! updates the ordering of each page with an id in the supplied ordering, to match it\'s position in that ordering' do
    page_1 = create(:take_part_page, ordering: 1)
    page_2 = create(:take_part_page, ordering: 12)
    page_3 = create(:take_part_page, ordering: 50)

    TakePartPage.reorder!([page_3.id, page_1.id, page_2.id])

    assert_equal 2, page_1.reload.ordering
    assert_equal 3, page_2.reload.ordering
    assert_equal 1, page_3.reload.ordering
  end

  test '.reorder! places any pages not in the supplied ordering at the end of the list' do
    page_1 = create(:take_part_page, ordering: 1)
    page_2 = create(:take_part_page, ordering: 12)
    page_3 = create(:take_part_page, ordering: 50)

    TakePartPage.reorder!([page_3.id])

    assert_equal 2, page_1.reload.ordering
    assert_equal 2, page_2.reload.ordering
    assert_equal 1, page_3.reload.ordering
  end

  test 'is in the Whitehall searchable_classes list' do
    assert Whitehall.searchable_classes.include?(TakePartPage)
  end

  test 'returns search index data suitable for Rummageable' do
    page = create(:take_part_page, title: 'Build a new polling station', summary: 'Help people vote!')

    assert_equal 'Build a new polling station', page.search_index["title"]
    assert_equal "/government/get-involved/take-part/build-a-new-polling-station", page.search_index['link']
    assert_equal page.body, page.search_index['indexable_content']
    assert_equal 'Help people vote!', page.search_index['description']
    assert_equal 'take_part', page.search_index['format']
  end

  test 'adds page to search index on creating' do
    page = build(:take_part_page)

    Whitehall::SearchIndex.expects(:add).with(page)

    page.save
  end

  test 'adds page to search index on updating' do
    page = create(:take_part_page)

    Whitehall::SearchIndex.expects(:add).with(page)

    page.title = 'Build a new polling station'
    page.save
  end

  test 'removes page from search index on destroying' do
    page = create(:take_part_page)

    Whitehall::SearchIndex.expects(:delete).with(page)

    page.destroy
  end

  test 'returns search index data for all take part pages' do
    create(:take_part_page, title: 'Build a new polling station', summary: 'Help people vote!', body: 'Everyone can build a building.')
    create(:take_part_page, title: 'Stand for election', summary: 'Help govern this country!', body: 'Maybe you can change the system from within?')

    results = TakePartPage.search_index.to_a

    assert_equal 2, results.length
    assert_equal({'title' => 'Build a new polling station',
                  'link' => "/government/get-involved/take-part/build-a-new-polling-station",
                  'indexable_content' => 'Everyone can build a building.',
                  'format' => 'take_part',
                  'description' => 'Help people vote!'}, results[0])
    assert_equal({'title' => 'Stand for election',
                  'link' => "/government/get-involved/take-part/stand-for-election",
                  'indexable_content' => 'Maybe you can change the system from within?',
                  'format' => 'take_part',
                  'description' => 'Help govern this country!'}, results[1])
  end

  should_not_accept_footnotes_in :body
end
