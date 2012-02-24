require "test_helper"

class PublicationsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_display_attachments_for :publication
  should_show_related_policies_and_policy_topics_for :publication
  should_show_the_countries_associated_with :publication
  should_display_inline_images_for :publication
  should_not_display_lead_image_for :publication

  test "should only display published publications" do
    archived_publication = create(:archived_publication)
    published_publication = create(:published_publication)
    draft_publication = create(:draft_publication)
    get :index

    assert_select_object(published_publication)
    refute_select_object(archived_publication)
    refute_select_object(draft_publication)
  end

  test "should avoid n+1 queries" do
    publications = []
    published_publications = mock("published_publications")
    published_publications.expects(:includes).with(:document_identity).returns(publications)
    published_publications.expects(:order).returns(published_publications)
    Publication.expects(:published).returns(published_publications)

    get :index
  end

  test 'show displays published publications' do
    published_publication = create(:published_publication)
    get :show, id: published_publication.document_identity
    assert_response :success
  end

  test "should show inapplicable nations" do
    published_publication = create(:published_publication)
    northern_ireland_inapplicability = published_publication.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://northern-ireland.com/")
    scotland_inapplicability = published_publication.nation_inapplicabilities.create!(nation: Nation.scotland)

    get :show, id: published_publication.document_identity

    assert_select inapplicable_nations_selector do
      assert_select "p", "This publication does not apply to Northern Ireland and Scotland."
      assert_select_object northern_ireland_inapplicability do
        assert_select "a[href='http://northern-ireland.com/']"
      end
      refute_select_object scotland_inapplicability
    end
  end

  test "should not explicitly say that publication applies to the whole of the UK" do
    published_publication = create(:published_publication)

    get :show, id: published_publication.document_identity

    refute_select inapplicable_nations_selector
  end

  test "should display publication metadata" do
    publication = create(:published_publication,
      publication_date: Date.parse("1916-05-31"),
      unique_reference: "unique-reference",
      isbn: "0099532816",
      research: true,
      order_url: "http://example.com/order-path"
    )

    get :show, id: publication.document_identity

    assert_select ".contextual_info" do
      assert_select ".publication_date", text: "31 May 1916"
      assert_select ".unique_reference", text: "unique-reference"
      assert_select ".isbn", text: "0099532816"
      assert_select ".research", text: "This is a research paper."
      assert_select "a.order_url[href='http://example.com/order-path']"
    end
  end

  test "should not mention the unique reference if there isn't one" do
    publication = create(:published_publication, unique_reference: '')

    get :show, id: publication.document_identity

    assert_select ".contextual_info" do
      refute_select ".unique_reference"
    end
  end

  test "should not mention the ISBN if there isn't one" do
    publication = create(:published_publication, isbn: '')

    get :show, id: publication.document_identity

    assert_select ".contextual_info" do
      refute_select ".isbn"
    end
  end

  test "should not display an order link if no order url exists" do
    publication = create(:published_publication, order_url: nil)

    get :show, id: publication.document_identity

    assert_select ".document_view" do
      refute_select "a.order_url"
    end
  end

  def assert_featured(docs)
    docs.each do |doc|
      assert_select '.featured_items' do 
        assert_select_object doc
      end
    end
  end

  def refute_featured(docs)
    docs.each do |doc|
      assert_select '.featured_items' do 
        refute_select_object doc
      end
    end
  end

  test "index with one featured shows one" do
    featured = 1.times.map { |n| create(:featured_publication, published_at: n.days.ago) }
    get :index

    assert_featured featured
  end

  test "index with two featured shows two" do
    featured = 2.times.map { |n| create(:featured_publication, published_at: n.days.ago) }
    get :index

    assert_featured featured
  end

  test "index with three featured shows only two" do
    featured = 3.times.map { |n| create(:featured_publication, published_at: n.days.ago) }
    get :index

    assert_featured featured[0..1]
    refute_featured featured[2..2]
    assert_select_object featured[2]
  end

  test "index with four featured shows four" do
    featured = 4.times.map { |n| create(:featured_publication, published_at: n.days.ago) }
    get :index

    assert_featured featured
  end

  test "index with five featured shows four" do
    featured = 5.times.map { |n| create(:featured_publication, published_at: n.days.ago) }

    get :index

    assert_featured featured[0..3]
    refute_featured featured[4..4]
    assert_select_object featured[4]
  end
  
end
