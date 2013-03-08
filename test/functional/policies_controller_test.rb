require "test_helper"

class PoliciesControllerTest < ActionController::TestCase
  include DocumentViewAssertions

  with_not_quite_as_fake_search
  should_be_a_public_facing_controller

  should_show_the_world_locations_associated_with :policy
  should_display_inline_images_for :policy
  should_show_inapplicable_nations :policy
  should_be_previewable :policy
  should_return_json_suitable_for_the_document_filter :policy

  test "index should handle badly formatted params for topics and departments" do
    get :index, departments: {'0' => "all"}, topics: {'0' => "all"}
  end

  view_test "index only lists documents in the given locale" do
    english_policy = create(:published_policy)
    french_policy = create(:published_policy, translated_into: [:fr])

    get :index, locale: 'fr'

    assert_select_object french_policy
    refute_select_object english_policy
  end

  view_test "index for non-english locales does not yet allow any filtering" do
    get :index, locale: 'fr'

    assert_select '.filter', count: 1
    assert_select '#filter-submit'
  end

  view_test "index for non-english locales skips results summary" do
    get :index, locale: 'fr'
    refute_select '#filter-results-summary'
  end

  view_test "show displays the date that the policy was updated" do
    policy = create(:published_policy)

    get :show, id: policy.document

    assert_select ".published-at[title=#{policy.public_timestamp.iso8601}]"
  end

  view_test "should not explicitly say that policy applies to the whole of the UK" do
    published_policy = create(:published_policy)

    get :show, id: published_policy.document

    refute_select inapplicable_nations_selector
  end

  view_test "show includes the main policy navigation" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, id: policy.document

    assert_select ".policy-navigation" do
      assert_select "a[href='#{policy_path(policy.document)}']"
      assert_select "a[href='#{policy_supporting_pages_path(policy.document)}']"
    end
  end

  view_test "show adds the current class to the policy link in the policy navigation" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, id: policy.document

    assert_select ".policy-navigation a.current[href='#{policy_path(policy.document)}']"
  end

  view_test "should render the content using govspeak markup" do
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

  view_test "should link to topics related to the policy" do
    first_topic = create(:topic)
    second_topic = create(:topic)
    edition = create(:published_policy, topics: [first_topic, second_topic])

    get :show, id: edition.document

    assert_select "a.topic", text: first_topic.name
    assert_select "a.topic", text: second_topic.name
  end

  view_test "should not show topics where none exist" do
    edition = create(:published_policy, topics: [])

    get :show, id: edition.document

    assert_select ".topics", count: 0
  end

  view_test "should link to organisations related to the policy" do
    first_org = create(:ministerial_department)
    second_org = create(:sub_organisation)
    edition = create(:published_policy, lead_organisations: [first_org], supporting_organisations: [second_org])

    get :show, id: edition.document

    assert_select_object first_org do
      assert_select "a[href='#{organisation_path(first_org)}']"
    end
    assert_select_prefix_object first_org, 'by-type' do
      assert_select "a[href='#{organisation_path(first_org)}']"
    end
    assert_select_prefix_object second_org, 'by-type' do
      assert_select "a[href='#{organisation_path(second_org)}']"
    end
  end

  view_test "should only link to organisations once if there are only lead organisations" do
    first_org = create(:organisation)
    edition = create(:published_policy, lead_organisations: [first_org])

    get :show, id: edition.document

    assert_select_object first_org
    refute_select_prefix_object first_org, 'by-type'
  end

  view_test "should link to ministers related to the policy" do
    role = create(:ministerial_role)
    appointment = create(:role_appointment, person: create(:person, forename: "minister-name"), role: role)
    edition = create(:published_policy, ministerial_roles: [appointment.role])

    get :show, id: edition.document

    assert_select "a.minister", text: "minister-name"
  end

  view_test "should use role name if no minister is in role related to the policy" do
    role = create(:ministerial_role)
    edition = create(:published_policy, ministerial_roles: [role])

    get :show, id: edition.document

    assert_select "a.minister", text: role.name
  end

  view_test "shows link to each policy section in the markdown" do
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

  view_test "show displays the policy team responsible for this policy" do
    policy_team = create(:policy_team, name: 'policy-team', email: 'policy-team@example.com')
    policy = create(:published_policy, policy_teams: [policy_team])
    get :show, id: policy.document
    assert_select_object policy_team do
      assert_select "a[href='#{policy_team_path(policy_team)}']", text: 'policy-team'
    end
  end

  view_test "show doesn't display the policy team section if the policy isn't associated with a policy team" do
    policy = create(:published_policy)
    get :show, id: policy.document
    refute_select '#policy_team'
  end

  view_test "activity displays the date that the policy was updated" do
    policy = create(:published_policy)
    publication = create(:published_publication, related_editions: [policy])

    get :activity, id: policy.document

    assert_select ".published-at[title=#{policy.public_timestamp.iso8601}]"
  end

  view_test "activity includes the main policy navigation" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)
    publication = create(:published_publication, related_editions: [policy])

    get :activity, id: policy.document

    assert_select ".policy-navigation" do
      assert_select "a[href='#{policy_path(policy.document)}']"
      assert_select "a[href='#{policy_supporting_pages_path(policy.document)}']"
      assert_select "a[href='#{activity_policy_path(policy.document)}']"
    end
  end

  view_test "activity displays the policy's topics" do
    topic = create(:topic)
    policy = create(:published_policy, topics: [topic])
    publication = create(:published_publication, related_editions: [policy])

    get :activity, id: policy.document

    assert_select_object topic
  end

  view_test "activity adds the current class to the activity link in the policy navigation" do
    policy = create(:published_policy)
    publication = create(:published_publication, related_editions: [policy])

    get :activity, id: policy.document

    assert_select ".policy-navigation a.current[href='#{activity_policy_path(policy.document)}']"
  end

  view_test "activity displays recently changed documents relating to the policy" do
    policy = create(:published_policy)
    publication = create(:published_publication, related_editions: [policy])
    consultation = create(:published_consultation, related_editions: [policy])
    news_article = create(:published_news_article, related_editions: [policy])
    speech = create(:published_speech, related_editions: [policy])

    get :activity, id: policy.document

    assert_select "#recently-changed" do
      assert_select_object publication
      assert_select_object consultation
      assert_select_object news_article
      assert_select_object speech
    end
  end

  view_test "activity displays metadata about the recently changed documents" do
    first_delivered_on = Time.zone.now
    policy = create(:published_policy)
    organisation = create(:organisation)
    speech = create(:published_speech, delivered_on: first_delivered_on, related_editions: [policy], organisations: [organisation])

    get :activity, id: policy.document

    assert_select "#recently-changed" do
      assert_select_object speech do
        assert_select ".display-type", text: "Speech"
        assert_select ".published-at[title='#{speech.public_timestamp.iso8601}']"
        assert_select ".organisations", text: organisation.acronym
      end
    end
  end

  test "activity sets Cache-Control: max-age to the time of the next scheduled publication" do
    policy = create(:published_policy)
    user = login_as(:departmental_editor)
    p1 = create(:published_publication, publication_date: Time.zone.now, related_editions: [policy])
    p2 = create(:draft_publication,
      scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 2,
      related_editions: [policy])
    p2.schedule_as(user, force: true)

    Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
      get :activity, id: policy.document
    end

    assert_cache_control("max-age=#{Whitehall.default_cache_max_age/2}")
  end

  view_test "activity uses publication_date to indicate when a publication was changed" do
    policy = create(:published_policy)
    edition = create(:published_publication,
      related_editions: [policy],
      publication_date: 2.days.ago.to_date)

    get :activity, id: policy.document

    assert_select_object edition do
      assert_select '.date', text: %r{#{edition.publication_date.to_s(:long_ordinal)}}
    end
  end

  view_test "activity distinguishes between published and updated documents" do
    policy = create(:published_policy)

    first_major_edition = create(:published_news_article, related_editions: [policy], published_major_version: 1)
    first_minor_edition = create(:published_news_article, related_editions: [policy], published_major_version: 1, published_minor_version: 1)
    second_major_edition = create(:published_news_article, related_editions: [policy], published_major_version: 2)

    get :activity, id: policy.document

    assert_select_object first_major_edition do
      assert_select '.document-row', text: /Published/
    end

    assert_select_object first_minor_edition do
      assert_select '.document-row', text: /Published/
    end

    assert_select_object second_major_edition do
      assert_select '.document-row', text: /Updated/
    end
  end

  test "activity orders recently changed documents in reverse chronological order" do
    policy = create(:published_policy)
    publication = create(:published_publication, publication_date: 4.weeks.ago, related_editions: [policy])
    consultation = create(:published_consultation, first_published_at: 1.weeks.ago, related_editions: [policy])
    news_article = create(:published_news_article, first_published_at: 3.weeks.ago, related_editions: [policy])
    speech = create(:published_speech, delivered_on: 2.weeks.ago, related_editions: [policy])

    get :activity, id: policy.document

    assert_equal [consultation, speech, news_article, publication], assigns(:recently_changed_documents)
  end

  view_test "activity shows the display type of speeches" do
    policy = create(:published_policy)
    speech = create(:published_speech, speech_type: SpeechType::WrittenStatement, related_editions: [policy])

    get :activity, id: policy.document

    assert_select ".speech .display-type", text: "Statement to Parliament"
  end

  view_test "supporting case studies are included in page" do
    policy = create(:published_policy)
    case_study = create(:published_case_study, related_editions: [policy])

    get :show, id: policy.document

    assert_select "aside#case-studies"
    assert_select_object case_study
  end

  view_test "link to case studies are included in policy navigation" do
    policy = create(:published_policy)
    case_study = create(:published_case_study, related_editions: [policy])

    get :show, id: policy.document
    assert_select "#document_sections:last-child", text: "Case studies"
    assert_select_object case_study do
      assert_select '.summary', text: case_study.summary
    end
  end

  view_test "activity link isn't shown on policies with no extra documents" do
    policy = create(:published_policy)

    get :show, id: policy.document
    refute_select '.policy-navigation'
  end

  view_test "class is applied to policies page when navigation isn't shown" do
    policy = create(:published_policy)

    get :show, id: policy.document
    assert_select ".no-navigation"
  end

  view_test "navigation is shown on pages with some supporting pages" do
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

  view_test 'activity has an atom feed autodiscovery link' do
    policy = create(:published_policy)
    publication = create(:published_publication, related_editions: [policy])

    get :activity, id: policy.document

    assert_select_autodiscovery_link activity_policy_url(policy.document, format: "atom")
  end

  view_test 'activity shows a link to the atom feed' do
    policy = create(:published_policy)
    publication = create(:published_publication, related_editions: [policy])

    get :activity, id: policy.document

    feed_url = ERB::Util.html_escape(activity_policy_url(policy.document, format: "atom"))
    assert_select "a.feed[href=?]", feed_url
  end

  view_test 'activity atom feed shows latest 10 documents' do
    policy = create(:published_policy)
    11.times do
      create(:published_publication, related_editions: [policy])
    end
    get :activity, id: policy.document, format: "atom"

    assert_select_atom_feed do
      assert_select 'feed > entry', count: 10
    end
  end

  view_test 'activity atom feed shows activity documents' do
    policy = create(:published_policy)
    publication = create(:published_publication, publication_date: 4.weeks.ago.to_date, related_editions: [policy])
    consultation = create(:published_consultation, opening_on: 1.weeks.ago.to_date, related_editions: [policy])
    news_article = create(:published_news_article, first_published_at: 3.weeks.ago, related_editions: [policy])
    speech = create(:published_speech, delivered_on: 2.weeks.ago.to_date, related_editions: [policy])

    get :activity, id: policy.document, format: "atom"

    assert_select_atom_feed do
      assert_select 'feed > id', 1
      assert_select 'feed > title', 1
      assert_select 'feed > updated', consultation.public_timestamp.iso8601
      assert_select 'feed > link[rel=?][type=?][href=?]', 'alternate', 'text/html', activity_policy_url(policy.document), 1

      assert_select_atom_entries([consultation, speech, news_article, publication])
    end
  end

  view_test 'activity shows a link to govdelivery if one exists' do
    policy = create(:published_policy, govdelivery_url: 'http://my-govdelivery-url.com')
    publication = create(:published_publication, publication_date: 4.weeks.ago, related_editions: [policy])

    get :activity, id: policy.document

    assert_select ".govdelivery[href='http://my-govdelivery-url.com']"
  end

  test "the format name is being set to policy" do
    policy = create(:published_policy)

    get :show, id: policy.document

    assert_equal "policy", response.headers["X-Slimmer-Format"]
  end

  test "the format name is being set to 'policy' on the latest (activity?) tab" do
    policy = create(:published_policy)

    get :activity, id: policy.document

    assert_equal "policy", response.headers["X-Slimmer-Format"]
  end
end
