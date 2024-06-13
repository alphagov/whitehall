require "test_helper"

class TakePartPageTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :take_part_page, :body

  test "invalid without a title" do
    assert_not build(:take_part_page, title: nil).valid?
  end

  test "limits title to a maximum of 255 characters" do
    page = build(:take_part_page)

    page.title = ("a" * 254)
    assert page.valid?

    page.title = ("a" * 255)
    assert page.valid?

    page.title = ("a" * 256)
    assert_not page.valid?
  end

  test "sets a slug from the organisation name" do
    page = create(:take_part_page, title: "Show me the money")
    assert_equal "show-me-the-money", page.slug
  end

  test "won't change the slug when the name is changed" do
    page = create(:take_part_page, title: "Show me the money")
    page.update!(title: "You had me at hello")
    assert_equal "show-me-the-money", page.slug
  end

  test "invalid without a body" do
    assert_not build(:take_part_page, body: nil).valid?
  end

  test "limits body to a maximum of (16.megabytes - 1) characters" do
    page = build(:take_part_page)

    page.body = ("a" * (16.megabytes - 2)) # 1 less
    assert page.valid?

    page.body += "a" # exact
    assert page.valid?

    page.body += "a" # 1 bigger
    assert_not page.valid?
  end

  test "invalid without a summary" do
    assert_not build(:take_part_page, summary: nil).valid?
  end

  test "limits summary to a maximum of 255 characters" do
    page = build(:take_part_page)

    page.summary = ("a" * 254)
    assert page.valid?

    page.summary = ("a" * 255)
    assert page.valid?

    page.summary = ("a" * 256)
    assert_not page.valid?
  end

  test "invalid without image on create" do
    take_part_page = build(:take_part_page)
    take_part_page.image = nil

    assert_not take_part_page.valid?
  end

  test "valid without image alt text on create" do
    assert build(:take_part_page, image_alt_text: nil).valid?
  end

  test "limits image alt text to a maximum of 255 characters" do
    page = build(:take_part_page)

    page.image_alt_text = ("a" * 254)
    assert page.valid?

    page.image_alt_text = ("a" * 255)
    assert page.valid?

    page.image_alt_text = ("a" * 256)
    assert_not page.valid?
  end

  test ".next_ordering returns us the next ordering available (1 more than the largest stored)" do
    TakePartPage.destroy_all
    assert_equal 1, TakePartPage.next_ordering

    create(:take_part_page, ordering: 20)
    assert_equal 21, TakePartPage.next_ordering

    create(:take_part_page, ordering: 10)
    assert_equal 21, TakePartPage.next_ordering

    create(:take_part_page, ordering: 99)
    assert_equal 100, TakePartPage.next_ordering
  end

  test "if ordering is not supplied, it is set to the next_ordering when saving" do
    page1 = create(:take_part_page, ordering: nil)
    assert_equal 1, page1.ordering

    page2 = create(:take_part_page, ordering: 20)
    assert_equal 20, page2.ordering
  end

  test "returns search index data suitable for Searchable" do
    page = create(:take_part_page, title: "Build a new polling station", summary: "Help people vote!", ordering: 1)

    assert_equal "Build a new polling station", page.search_index["title"]
    assert_equal "/government/get-involved/take-part/build-a-new-polling-station", page.search_index["link"]
    assert_equal page.body, page.search_index["indexable_content"]
    assert_equal "Help people vote!", page.search_index["description"]
    assert_equal "take_part", page.search_index["format"]
    assert_equal 1, page.search_index["ordering"]
  end

  test "adds page to search index on creating" do
    page = build(:take_part_page)

    Whitehall::SearchIndex.expects(:add).with(page)

    page.save!
  end

  test "adds page to search index on updating" do
    page = create(:take_part_page)

    Whitehall::SearchIndex.expects(:add).with(page)

    page.title = "Build a new polling station"
    page.save!
  end

  test "removes page from search index on destroying" do
    page = create(:take_part_page)

    Whitehall::SearchIndex.expects(:delete).with(page)

    page.destroy!
  end

  test "returns search index data for all take part pages" do
    create(:take_part_page, content_id: "845593d6-273d-4440-b44a-8c44ab530c9e", title: "Build a new polling station", summary: "Help people vote!", body: "Everyone can build a building.", ordering: 1)
    create(:take_part_page, content_id: "a7a3a7f3-f967-4723-8de3-1e2d8f9fb4cb", title: "Stand for election", summary: "Help govern this country!", body: "Maybe you can change the system from within?", ordering: 1)

    results = TakePartPage.search_index.to_a

    assert_equal 2, results.length
    assert_equal(
      { "title" => "Build a new polling station",
        "content_id" => "845593d6-273d-4440-b44a-8c44ab530c9e",
        "link" => "/government/get-involved/take-part/build-a-new-polling-station",
        "indexable_content" => "Everyone can build a building.",
        "format" => "take_part",
        "description" => "Help people vote!",
        "ordering" => 1 },
      results[0],
    )
    assert_equal(
      { "title" => "Stand for election",
        "content_id" => "a7a3a7f3-f967-4723-8de3-1e2d8f9fb4cb",
        "link" => "/government/get-involved/take-part/stand-for-election",
        "indexable_content" => "Maybe you can change the system from within?",
        "format" => "take_part",
        "description" => "Help govern this country!",
        "ordering" => 1 },
      results[1],
    )
  end

  test "public_path returns the correct path" do
    object = create(:take_part_page, slug: "foo")
    assert_equal "/government/get-involved/take-part/foo", object.public_path
  end

  test "public_path returns the correct path with options" do
    object = create(:take_part_page, slug: "foo")
    assert_equal "/government/get-involved/take-part/foo?cachebust=123", object.public_path(cachebust: "123")
  end

  test "public_url returns the correct path for a TakePart object" do
    object = create(:take_part_page, slug: "foo")
    assert_equal "https://www.test.gov.uk/government/get-involved/take-part/foo", object.public_url
  end

  test "public_url returns the correct path for a TakePart object with options" do
    object = create(:take_part_page, slug: "foo")
    assert_equal "https://www.test.gov.uk/government/get-involved/take-part/foo?cachebust=123", object.public_url(cachebust: "123")
  end

  test "#TakePartPage#patch_getinvolved_page_links republishes the get_involved page" do
    take_part_page1 = create(:take_part_page, ordering: 2)
    take_part_page2 = create(:take_part_page, ordering: 1)

    TakePartPage.patch_getinvolved_page_links

    assert_publishing_api_patch_links(
      TakePartPage::GET_INVOLVED_CONTENT_ID,
      links: {
        take_part_pages: [take_part_page2.content_id, take_part_page1.content_id],
      },
    )
  end

  should_not_accept_footnotes_in :body
end
