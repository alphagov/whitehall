require "test_helper"

class PoliciesControllerTest < ActionController::TestCase
  include DocumentViewAssertions

  should_be_a_public_facing_controller
  should_render_a_list_of :policies
  should_show_the_countries_associated_with :policy
  should_display_inline_images_for :policy
  should_not_display_lead_image_for :policy
  should_show_inapplicable_nations :policy
  should_show_change_notes_on_action :policy, :show do |policy|
    get :show, id: policy.document
  end

  test "show displays the date that the policy was updated" do
    policy = create(:published_policy)

    get :show, id: policy.document

    assert_select ".published-at[title=#{policy.published_at.iso8601}]"
  end

  test "should not explicitly say that policy applies to the whole of the UK" do
    published_policy = create(:published_policy)

    get :show, id: published_policy.document

    refute_select inapplicable_nations_selector
  end

  test "show includes the main policy navigation" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, id: policy.document

    assert_select ".policy-navigation" do
      assert_select "a[href='#{policy_path(policy.document)}']"
      assert_select "a[href='#{policy_supporting_pages_path(policy.document)}']"
    end
  end

  test "show adds the current class to the policy link in the policy navigation" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, id: policy.document

    assert_select ".policy-navigation a.current[href='#{policy_path(policy.document)}']"
  end

  test "should render the content using govspeak markup" do
    published_policy = create(:published_policy, body: "body-in-govspeak")
    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :show, id: published_policy.document
    end

    assert_select ".body", text: "body-in-html"
  end

  test "should render 404 if the document doesn't have a published edition" do
    document = create(:document)
    get :show, id: document

    assert_response :not_found
  end

  test "should display the published edition" do
    published_edition = create(:published_policy)
    draft = published_edition.create_draft(create(:user))
    document = draft.document

    get :show, id: document

    assert_response :success
    assert_equal published_edition, assigns(:document)
  end

  test "should link to topics related to the policy" do
    first_topic = create(:topic)
    second_topic = create(:topic)
    edition = create(:published_policy, topics: [first_topic, second_topic])

    get :show, id: edition.document

    assert_select ".topics a.topic", text: first_topic.name
    assert_select ".topics a.topic", text: second_topic.name
  end

  test "should not show topics where none exist" do
    edition = create(:published_policy, topics: [])

    get :show, id: edition.document

    assert_select ".topics", count: 0
  end

  test "should link to organisations related to the policy" do
    first_org = create(:organisation, logo_formatted_name: "first", active: true)
    second_org = create(:organisation, logo_formatted_name: "second", active: true)
    edition = create(:published_policy, organisations: [first_org, second_org])

    get :show, id: edition.document

    assert_select_object first_org do
      assert_select "a[href='#{organisation_path(first_org)}']", first_org.logo_formatted_name
    end
    assert_select_object second_org do
      assert_select "a[href='#{organisation_path(second_org)}']", second_org.logo_formatted_name
    end
  end

  test "should not link to inactive orgs" do
    first_org = create(:organisation, logo_formatted_name: "first\nalso first", active: true)
    second_org = create(:organisation, logo_formatted_name: "second", active: false)
    edition = create(:published_policy, organisations: [first_org, second_org])

    get :show, id: edition.document

    assert_select_object first_org do
      assert_select "a[href='#{organisation_path(first_org)}']", first_org.logo_formatted_name
    end
    assert_select_object second_org do
      refute_select "a[href='#{organisation_path(second_org)}']", text: second_org.logo_formatted_name
    end
  end

  test "should link to ministers related to the policy" do
    role = create(:ministerial_role)
    appointment = create(:role_appointment, person: create(:person, forename: "minister-name"), role: role)
    edition = create(:published_policy, ministerial_roles: [appointment.role])

    get :show, id: edition.document

    assert_select "#document-ministers a.minister", text: "minister-name"
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

    get :show, id: policy.document
    assert_select "ol#document_sections" do
      assert_select "li a[href='#{public_document_path(policy, anchor: 'first-section')}']", 'First Section'
      assert_select "li a[href='#{public_document_path(policy, anchor: 'another-bit')}']", 'Another Bit'
      assert_select "li a[href='#{public_document_path(policy, anchor: 'final-part')}']", 'Final Part'
    end
  end

  test "show displays the policy team responsible for this policy" do
    policy_team = create(:policy_team, name: 'policy-team', email: 'policy-team@example.com')
    policy = create(:published_policy, policy_team: policy_team)
    get :show, id: policy.document
    assert_select_object policy_team do
      assert_select "a[href='#{policy_team_path(policy_team)}']", text: 'policy-team'
    end
  end

  test "show doesn't display the policy team section if the policy isn't associated with a policy team" do
    policy = create(:published_policy)
    get :show, id: policy.document
    refute_select '#policy_team'
  end

  test "activity displays the date that the policy was updated" do
    policy = create(:published_policy)
    publication = create(:published_publication, related_policies: [policy])

    get :activity, id: policy.document

    assert_select ".published-at[title=#{policy.published_at.iso8601}]"
  end

  test "activity includes the main policy navigation" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)
    publication = create(:published_publication, related_policies: [policy])

    get :activity, id: policy.document

    assert_select ".policy-navigation" do
      assert_select "a[href='#{policy_path(policy.document)}']"
      assert_select "a[href='#{policy_supporting_pages_path(policy.document)}']"
      assert_select "a[href='#{activity_policy_path(policy.document)}']"
    end
  end

  test "activity adds the current class to the activity link in the policy navigation" do
    policy = create(:published_policy)
    publication = create(:published_publication, related_policies: [policy])

    get :activity, id: policy.document

    assert_select ".policy-navigation a.current[href='#{activity_policy_path(policy.document)}']"
  end

  test "activity displays recently changed documents relating to the policy" do
    policy = create(:published_policy)
    publication = create(:published_publication, related_policies: [policy])
    consultation = create(:published_consultation, related_policies: [policy])
    news_article = create(:published_news_article, related_policies: [policy])
    speech = create(:published_speech, related_policies: [policy])

    get :activity, id: policy.document

    assert_select "#recently-changed" do
      assert_select_object publication
      assert_select_object consultation
      assert_select_object news_article
      assert_select_object speech
    end
  end

  test "activity displays metadata about the recently changed documents" do
    published_at = Time.zone.now
    policy = create(:published_policy)
    speech = create(:published_speech, published_at: published_at, related_policies: [policy])

    get :activity, id: policy.document

    assert_select "#recently-changed" do
      assert_select_object speech do
        assert_select ".document-row .type", text: "Speech"
        assert_select ".document-row .published-at[title='#{published_at.iso8601}']"
      end
    end
  end

  test "activity distinguishes between published and updated documents" do
    policy = create(:published_policy)

    first_edition = create(:published_news_article, related_policies: [policy])
    updated_edition = create(:published_news_article, related_policies: [policy], published_at: Time.zone.now, first_published_at: 1.day.ago)

    get :activity, id: policy.document

    assert_select_object first_edition do
      assert_select '.document-row', text: /Published/
    end

    assert_select_object updated_edition do
      assert_select '.document-row', text: /Updated/
    end
  end

  test "activity orders recently changed documents relating to the policy most recent first" do
    policy = create(:published_policy)
    publication = create(:published_publication, published_at: 4.weeks.ago, related_policies: [policy])
    consultation = create(:published_consultation, published_at: 1.weeks.ago, related_policies: [policy])
    news_article = create(:published_news_article, published_at: 3.weeks.ago, related_policies: [policy])
    speech = create(:published_speech, published_at: 2.weeks.ago, related_policies: [policy])

    get :activity, id: policy.document

    assert_equal [consultation, speech, news_article, publication], assigns(:recently_changed_documents)
  end

  test "supporting case studies are included in page" do
    policy = create(:published_policy)
    case_study = create(:published_case_study, related_policies: [policy])

    get :show, id: policy.document

    assert_select "aside#case-studies"
    assert_select_object case_study
  end

  test "link to case studies are included in policy navigation" do
    policy = create(:published_policy)
    case_study = create(:published_case_study, related_policies: [policy])

    get :show, id: policy.document
    assert_select "#document_sections:last-child", text: "Case studies"
    assert_select_object case_study do
      assert_select '.summary', text: case_study.summary
    end
  end

  test "activity link isn't shown on policies with no extra documents" do
    policy = create(:published_policy)

    get :show, id: policy.document
    refute_select '.policy-navigation'
  end

  test "class is applied to policies page when navigation isn't shown" do
    policy = create(:published_policy)

    get :show, id: policy.document
    assert_select ".no-navigation"
  end

  test "navigation is shown on pages with some supporting pages" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, id: policy.document

    assert_select '.policy-navigation' do
      assert_select "a[href='#{policy_path(policy.document)}']"
      assert_select "a[href='#{policy_supporting_pages_path(policy.document)}']"
    end
  end

  test "activity 404s if there's no actual activity" do
    policy = create(:published_policy)

    get :activity, id: policy.document
    assert_response :not_found
  end

  test 'activity has an atom feed autodiscovery link' do
    policy = create(:published_policy)
    publication = create(:published_publication, published_at: 4.weeks.ago, related_policies: [policy])
    consultation = create(:published_consultation, published_at: 1.weeks.ago, related_policies: [policy])
    news_article = create(:published_news_article, published_at: 3.weeks.ago, related_policies: [policy])
    speech = create(:published_speech, published_at: 2.weeks.ago, related_policies: [policy])

    get :activity, id: policy.document

    assert_select_autodiscovery_link activity_policy_url(policy.document, format: "atom")
  end

  test 'activity shows a link to the atom feed' do

    policy = create(:published_policy)
    publication = create(:published_publication, published_at: 4.weeks.ago, related_policies: [policy])
    consultation = create(:published_consultation, published_at: 1.weeks.ago, related_policies: [policy])
    news_article = create(:published_news_article, published_at: 3.weeks.ago, related_policies: [policy])
    speech = create(:published_speech, published_at: 2.weeks.ago, related_policies: [policy])

    get :activity, id: policy.document

    feed_url = ERB::Util.html_escape(activity_policy_url(policy.document, format: "atom"))
    assert_select "a.feed[href=?]", feed_url
  end

  test 'activity atom feed shows activity documents' do
    policy = create(:published_policy)
    publication = create(:published_publication, published_at: 4.weeks.ago, related_policies: [policy])
    consultation = create(:published_consultation, published_at: 1.weeks.ago, related_policies: [policy])
    news_article = create(:published_news_article, published_at: 3.weeks.ago, related_policies: [policy])
    speech = create(:published_speech, published_at: 2.weeks.ago, related_policies: [policy])

    get :activity, id: policy.document, format: "atom"

    assert_select_atom_feed do
      assert_select 'feed > id', 1
      assert_select 'feed > title', 1
      assert_select 'feed > link[rel=?][type=?][href=?]', 'alternate', 'text/html', activity_policy_url(policy.document), 1

      assert_select 'feed > entry' do |entries|
        entries.zip([consultation, speech, news_article, publication]).each do |entry, document|
          assert_select entry, 'entry > title', text: document.title
        end
      end
    end
  end
end
