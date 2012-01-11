require "test_helper"

class PublicationsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_display_attachments_for :publication
  should_show_related_policies_and_policy_areas_for :publication
  should_show_the_countries_associated_with :publication

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

  test "should explain that publication applies to the whole of the UK" do
    published_publication = create(:published_publication)

    get :show, id: published_publication.document_identity

    assert_select inapplicable_nations_selector do
      assert_select "p", "This publication applies to the whole of the UK."
    end
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
      assert_select ".publication_date", text: "May 31st, 1916"
      assert_select ".unique_reference", text: "unique-reference"
      assert_select ".isbn", text: "0099532816"
      assert_select ".research", text: "This is a research paper."
      assert_select "a.order_url[href='http://example.com/order-path']"
    end
  end

  test "should not display an order link if no order url exists" do
    publication = create(:published_publication, order_url: nil)

    get :show, id: publication.document_identity

    assert_select ".document_view" do
      refute_select "a.order_url"
    end
  end
end
