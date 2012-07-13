require "test_helper"

class SupportingPagesControllerTest < ActionController::TestCase
  include DocumentViewAssertions

  should_be_a_public_facing_controller
  should_show_change_notes_on_action :policy, :show do |policy|
    supporting_page = create(:supporting_page, edition: policy)
    get :show, policy_id: policy.document, id: supporting_page
  end

  test "index redirects to the first supporting page" do
    policy = create(:published_policy)
    supporting_page_1 = create(:supporting_page, title: "supporting-page-1", edition: policy)
    supporting_page_2 = create(:supporting_page, title: "supporting-page-2", edition: policy)

    get :index, policy_id: policy.document

    assert_redirected_to policy_supporting_page_path(policy.document, supporting_page_1)
  end

  test "index should return a 404 response if there aren't any supporting pages" do
    policy = create(:published_policy)
    get :index, policy_id: policy.document
    assert_response 404
  end

  test "show displays the date that the policy was updated" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_select ".updated_at[title=#{policy.updated_at.iso8601}]"
  end

  test "show includes the main policy navigation" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_select ".policy-navigation" do
      assert_select "a[href='#{policy_path(policy.document)}']"
      assert_select "a[href='#{policy_supporting_pages_path(policy.document)}']"
    end
  end

  test "show adds the current class to the supporting pages link in the policy navigation" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_select ".policy-navigation a.current[href='#{policy_supporting_pages_path(policy.document)}']"
  end

  test "shows the body using govspeak markup" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy, body: "body-in-govspeak")
    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :show, policy_id: policy.document, id: supporting_page
    end

    assert_select ".body", text: "body-in-html"
  end

  test "doesn't show supporting page if parent isn't published" do
    policy = create(:draft_policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_response :not_found
  end

  test "should show inapplicable nations" do
    policy = create(:published_policy)
    northern_ireland_inapplicability = policy.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://northern-ireland.com/")
    scotland_inapplicability = policy.nation_inapplicabilities.create!(nation: Nation.scotland)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_select inapplicable_nations_selector do
      assert_select "p", "This policy does not apply to Northern Ireland and Scotland."
      assert_select_object northern_ireland_inapplicability do
        assert_select "a[href='http://northern-ireland.com/']"
      end
      refute_select_object scotland_inapplicability
    end
  end

  test "should not explicitly say that policy applies to the whole of the UK" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    refute_select inapplicable_nations_selector
  end

  test "show lists supporting pages when there are some" do
    policy = create(:published_policy)
    first_supporting_page = create(:supporting_page, edition: policy)
    second_supporting_page = create(:supporting_page, edition: policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_select ".contextual-info nav.supporting_pages" do
      assert_select "a[href='#{policy_supporting_page_path(policy.document, first_supporting_page)}']", text: first_supporting_page.title
      assert_select "a[href='#{policy_supporting_page_path(policy.document, second_supporting_page)}']", text: second_supporting_page.title
    end
  end

  test "should display the published edition" do
    policy = create(:published_policy)
    draft = policy.create_draft(create(:user))
    document = draft.document

    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: document, id: supporting_page

    assert_response :success
    assert_equal policy, assigns(:policy)
  end

  test "should link to topics from within the metadata navigation" do
    first_topic = create(:topic)
    second_topic = create(:topic)
    policy = create(:published_policy, topics: [first_topic, second_topic])
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_select ".meta-topic a.topic", text: first_topic.name
    assert_select ".meta-topic a.topic", text: second_topic.name
  end

  test "should link to organisations from within the metadata navigation" do
    first_org = create(:organisation, logo_formatted_name: "first")
    second_org = create(:organisation, logo_formatted_name: "second")
    policy = create(:published_policy, organisations: [first_org, second_org])
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_select "#document-organisations a", text: first_org.logo_formatted_name
    assert_select "#document-organisations a", text: second_org.logo_formatted_name
  end

  test "should link to ministers from within the metadata navigation" do
    role = create(:ministerial_role)
    appointment = create(:role_appointment, person: create(:person, forename: "minister-name"), role: role)
    policy = create(:published_policy, ministerial_roles: [appointment.role])
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_select "#document-ministers a.minister", text: "minister-name"
  end

  test "should not apply active class to the parent policy page navigation heading" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_select "section.contextual-info .active",
      text: policy.title,
      count: 0
  end

  test "should apply active class to the current supporting page navigation heading" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy, title: "This is the active one")
    other_supporting_page = create(:supporting_page, edition: policy, title: "This is an inactive one")

    get :show, policy_id: policy.document, id: supporting_page

    assert_select "section.contextual-info .active",
      text: supporting_page.title,
      count: 1
    assert_select "section.contextual-info .active",
      text: other_supporting_page.title,
      count: 0
  end

  test "should use supporting page title as page title" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_select "title", text: Regexp.new(supporting_page.title)
  end

  test "should use supporting page title as h1" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_select "h1", text: supporting_page.title
  end

  test "show displays the policy team responsible for this policy" do
    policy_team = create(:policy_team, email: 'policy-team@example.com')
    policy = create(:published_policy, policy_team: policy_team)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_select_object policy_team do
      assert_select "a[href='#{policy_team_path(policy_team)}']", text: 'policy-team-name'
    end

  end

  test "show doesn't display the policy team section if the policy isn't associated with a policy team" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    refute_select policy_team_selector
  end

  test "shows correct sub navigation when viewing supporting details" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_select '.policy-navigation' do
      assert_select "a[href='#{policy_path(policy.document)}']"
      assert_select "a[href='#{policy_supporting_pages_path(policy.document)}']"
    end
  end

  test "shows activity link when viewing supporting details" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)
    speech = create(:published_speech, published_at: 2.weeks.ago, related_policies: [policy])

    get :show, policy_id: policy.document, id: supporting_page

    assert_select '.policy-navigation' do
      assert_select "a[href='#{policy_path(policy.document)}']"
      assert_select "a[href='#{policy_supporting_pages_path(policy.document)}']"
      assert_select "a[href='#{activity_policy_path(policy.document)}']"
    end
  end

end
