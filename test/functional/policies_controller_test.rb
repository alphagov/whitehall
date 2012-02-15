require "test_helper"

class PoliciesControllerTest < ActionController::TestCase
  include PolicyViewAssertions

  should_be_a_public_facing_controller
  should_render_a_list_of :policies
  should_show_the_countries_associated_with :policy
  should_display_inline_images_for :policy

  test "should show inapplicable nations" do
    published_policy = create(:published_policy)
    northern_ireland_inapplicability = published_policy.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://northern-ireland.com/")
    scotland_inapplicability = published_policy.nation_inapplicabilities.create!(nation: Nation.scotland)

    get :show, id: published_policy.document_identity

    assert_select inapplicable_nations_selector do
      assert_select "p", "This policy does not apply to Northern Ireland and Scotland."
      assert_select_object northern_ireland_inapplicability do
        assert_select "a[href='http://northern-ireland.com/']"
      end
      refute_select_object scotland_inapplicability
    end
  end

  test "should not explicitly say that policy applies to the whole of the UK" do
    published_policy = create(:published_policy)

    get :show, id: published_policy.document_identity

    refute_select inapplicable_nations_selector
  end

  test "show displays recently changed documents relating to the policy" do
    policy = create(:published_policy)
    publication = create(:published_publication, related_policies: [policy])
    consultation = create(:published_consultation, related_policies: [policy])
    news_article = create(:published_news_article, related_policies: [policy])
    speech = create(:published_speech, related_policies: [policy])

    get :show, id: policy.document_identity

    assert_select "#recently-changed" do
      assert_select_object publication
      assert_select_object consultation
      assert_select_object news_article
      assert_select_object speech
    end
  end

  test "show displays metadata about the recently changed documents" do
    published_at = Time.zone.now
    policy = create(:published_policy)
    speech = create(:published_speech, published_at: published_at, related_policies: [policy])

    get :show, id: policy.document_identity

    assert_select "#recently-changed" do
      assert_select_object speech do
        assert_select ".metadata .document_type", text: "Speech"
        assert_select ".metadata .published_at[title='#{published_at.iso8601}']"
      end
    end
  end

  test "show distinguishes between published and updated documents" do
    policy = create(:published_policy)

    first_edition = create(:published_news_article, related_policies: [policy])
    updated_edition = create(:published_news_article, related_policies: [policy], published_at: Time.zone.now, first_published_at: 1.day.ago)

    get :show, id: policy.document_identity

    assert_select_object first_edition do
      assert_select '.metadata', text: /News article(\s*)published/
    end

    assert_select_object updated_edition do
      assert_select '.metadata', text: /News article(\s*)updated/
    end
  end

  test "show orders recently changed documents relating to the policy most recent first" do
    policy = create(:published_policy)
    publication = create(:published_publication, published_at: 4.weeks.ago, related_policies: [policy])
    consultation = create(:published_consultation, published_at: 1.weeks.ago, related_policies: [policy])
    news_article = create(:published_news_article, published_at: 3.weeks.ago, related_policies: [policy])
    speech = create(:published_speech, published_at: 2.weeks.ago, related_policies: [policy])

    get :show, id: policy.document_identity

    assert_equal [consultation, speech, news_article, publication], assigns[:recently_changed_documents]
  end

  test "show displays related published publications" do
    published_policy = create(:published_policy)
    related_publication = create(:published_publication, title: "Voting Patterns", related_policies: [published_policy])

    get :show, id: published_policy.document_identity

    assert_select related_publications_selector do
      assert_select_object related_publication
    end
  end

  test "show excludes related unpublished publications" do
    published_policy = create(:published_policy)
    related_publication = create(:draft_publication, title: "Voting Patterns", related_policies: [published_policy])

    get :show, id: published_policy.document_identity

    refute_select related_publications_selector
  end

  test "show displays related published consultations" do
    published_policy = create(:published_policy)
    related_consultation = create(:published_consultation, title: "Consultation on Voting Patterns",
                                  related_policies: [published_policy])

    get :show, id: published_policy.document_identity

    assert_select related_consultations_selector do
      assert_select_object related_consultation
    end
  end

  test "show excludes related unpublished consultations" do
    published_policy = create(:published_policy)
    related_consultation = create(:draft_consultation, title: "Consultation on Voting Patterns",
                                  related_policies: [published_policy])

    get :show, id: published_policy.document_identity

    refute_select related_consultations_selector
  end

  test "show displays related news articles" do
    published_policy = create(:published_policy)
    related_news_article = create(:published_news_article, title: "News about Voting Patterns",
                                  related_policies: [published_policy])

    get :show, id: published_policy.document_identity

    assert_select related_news_articles_selector do
      assert_select_object related_news_article
    end
  end

  test "show excludes related unpublished news articles" do
    published_policy = create(:published_policy)
    related_news_article = create(:draft_news_article, title: "News about Voting Patterns",
                                  related_policies: [published_policy])

    get :show, id: published_policy.document_identity

    refute_select related_news_articles_selector
  end

  test "show lists supporting pages when there are some" do
    published_document = create(:published_policy)
    first_supporting_page = create(:supporting_page, document: published_document)
    second_supporting_page = create(:supporting_page, document: published_document)

    get :show, id: published_document.document_identity

    assert_select ".contextual_info nav.supporting_pages" do
      assert_select "a[href='#{policy_supporting_page_path(published_document.document_identity, first_supporting_page)}']", text: first_supporting_page.title
      assert_select "a[href='#{policy_supporting_page_path(published_document.document_identity, second_supporting_page)}']", text: second_supporting_page.title
    end
  end

  test "doesn't show supporting pages list when empty" do
    published_document = create(:published_policy)

    get :show, id: published_document.document_identity

    refute_select supporting_pages_selector
  end

  test "should render the content using govspeak markup" do
    published_policy = create(:published_policy, body: "body-in-govspeak")
    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :show, id: published_policy.document_identity
    end

    assert_select ".body", text: "body-in-html"
  end

  test "should render 404 if the document doesn't have a published document" do
    document_identity = create(:document_identity)
    get :show, id: document_identity

    assert_response :not_found
  end

  test "should display the published document" do
    published_document = create(:published_policy)
    draft = published_document.create_draft(create(:user))
    document_identity = draft.document_identity

    get :show, id: document_identity

    assert_response :success
    assert_equal published_document, assigns[:document]
  end

  test "should link to policy areas from within the metadata navigation" do
    first_policy_area = create(:policy_area)
    second_policy_area = create(:policy_area)
    document = create(:published_policy, policy_areas: [first_policy_area, second_policy_area])

    get :show, id: document.document_identity

    assert_select "#{metadata_nav_selector} a.policy_area", text: first_policy_area.name
    assert_select "#{metadata_nav_selector} a.policy_area", text: second_policy_area.name
  end

  test "should link to organisations from within the metadata navigation" do
    first_org = create(:organisation)
    second_org = create(:organisation)
    document = create(:published_policy, organisations: [first_org, second_org])

    get :show, id: document.document_identity

    assert_select "#{metadata_nav_selector} a.organisation", text: first_org.name
    assert_select "#{metadata_nav_selector} a.organisation", text: second_org.name
  end

  test "should link to ministers from within the metadata navigation" do
    role = create(:ministerial_role)
    appointment = create(:role_appointment, person: create(:person, forename: "minister-name"), role: role)
    document = create(:published_policy, ministerial_roles: [appointment.role])

    get :show, id: document.document_identity

    assert_select "#{metadata_nav_selector} a.minister", text: "minister-name"
  end

  test "shows link to policy overview" do
    policy = create(:published_policy)
    get :show, id: policy.document_identity
    assert_select "a[href='#{policy_path(policy.document_identity)}#policy_view']", text: policy.title
  end

  test "shows link to each policy section in the markdown" do
    policy = create(:published_policy, body: %{
## First Section

Some content

## Another Bit

More content

## Final Part

That's all
})

    get :show, id: policy.document_identity
    assert_select_policy_section_link policy, 'First Section', 'first-section'
    assert_select_policy_section_link policy, 'Another Bit', 'another-bit'
    assert_select_policy_section_link policy, 'Final Part', 'final-part'
  end

  test "show links to related news articles on policy if any" do
    policy = create(:published_policy)
    related_news_article = create(:published_news_article, title: "News about Voting Patterns",
                                  related_policies: [policy])
    get :show, id: policy.document_identity
    assert_select_policy_section_link policy, 'Related news', 'related-news-articles'
  end

  test "show doesn't link to related news articles on policy if none exist" do
    policy = create(:published_policy)
    get :show, id: policy.document_identity
    refute_select_policy_section_list
  end

  test "show links to related speeches on policy if any" do
    policy = create(:published_policy)
    related_speech = create(:published_speech, title: "Speech about Voting Patterns",
                            related_policies: [policy])
    get :show, id: policy.document_identity
    assert_select_policy_section_link policy, 'Related speeches', 'related-speeches'
  end

  test "show doesn't link to related speeches on policy if none exist" do
    policy = create(:published_policy)
    get :show, id: policy.document_identity
    refute_select_policy_section_list
  end

  test "show links to related consultations on policy if any" do
    policy = create(:published_policy)
    related_consultation = create(:published_consultation, title: "Consultation about Voting Patterns",
                                  related_policies: [policy])
    get :show, id: policy.document_identity
    assert_select_policy_section_link policy, 'Related consultations', 'related-consultations'
  end

  test "show doesn't link to related consultations on policy if none exist" do
    policy = create(:published_policy)
    get :show, id: policy.document_identity
    refute_select_policy_section_list
  end

  test "show links to related publications on policy if any" do
    policy = create(:published_policy)
    related_publication = create(:published_publication, title: "Consultation about Voting Patterns",
                                 related_policies: [policy])
    get :show, id: policy.document_identity
    assert_select_policy_section_link policy, 'Related publications', 'related-publications'
  end

  test "show doesn't link to related publications on policy if none exist" do
    policy = create(:published_policy)
    get :show, id: policy.document_identity
    refute_select_policy_section_list
  end

  test "show displays change history in reverse chronological order" do
    editions = []
    editions << create(:published_policy, change_note: "Third go.", published_at: 1.month.ago)
    document_identity = editions.first.document_identity
    editions << create(:archived_policy, change_note: "Second attempt.", document_identity: document_identity, published_at: 2.months.ago)
    editions << create(:archived_policy, change_note: "First effort.", document_identity: document_identity, published_at: 3.months.ago)

    get :show, id: document_identity

    assert_select ".policy .change_notes li" do |list_items|
      list_items.each_with_index do |list_item, index|
        assert_select list_item, ".published_at[title='#{editions[index].published_at.iso8601}']"
        assert_select list_item, "p", text: editions[index].change_note
      end
    end
  end

  test "show displays default change note for first edition" do
    first_edition = create(:published_policy, change_note: nil, published_at: 1.month.ago)

    get :show, id: first_edition.document_identity

    assert_select ".policy .change_notes li" do
      assert_select ".published_at[title='#{first_edition.published_at.iso8601}']"
      assert_select "p", text: "First published."
    end
  end

  test "show does not display blank change notes in change history" do
    second_edition = create(:published_policy, change_note: nil, published_at: 1.months.ago)
    document_identity = second_edition.document_identity
    first_edition = create(:archived_policy, change_note: "First effort.", document_identity: document_identity, published_at: 2.months.ago)

    get :show, id: document_identity

    assert_select ".policy .change_notes li" do
      refute_select ".published_at[title='#{second_edition.published_at.iso8601}']"
      refute_select "p", text: ""
    end
  end
end