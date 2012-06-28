require "test_helper"

class SupportingPagesControllerTest < ActionController::TestCase
  include DocumentViewAssertions

  should_be_a_public_facing_controller

  test "index links to supporting pages" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, title: "supporting-page-title", edition: policy)
    get :index, policy_id: policy.document
    path = policy_supporting_page_path(policy.document, supporting_page)
    assert_select supporting_pages_selector do
      assert_select_object supporting_page do
        assert_select "a[href=#{path}]"
        assert_select ".title", text: "supporting-page-title"
      end
    end
  end

  test "index only shows supporting pages for the parent policy" do
    policy = create(:published_policy)
    other_supporting_page = create(:supporting_page)
    get :index, policy_id: policy.document
    refute_select_object other_supporting_page
  end

  test "index doesn't display an empty list if there aren't any supporting pages" do
    policy = create(:published_policy)
    get :index, policy_id: policy.document
    refute_select "#{supporting_pages_selector} ul"
  end

  test "shows link to policy overview" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_select "a[href='#{policy_path(policy.document)}#top']", text: policy.title
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

    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_select_document_section_link policy, 'First Section', 'first-section'
    assert_select_document_section_link policy, 'Another Bit', 'another-bit'
    assert_select_document_section_link policy, 'Final Part', 'final-part'
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

    assert_select ".contextual_info nav.supporting_pages" do
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

    assert_select "#document_topics li.topic a", text: first_topic.name
    assert_select "#document_topics li.topic a", text: second_topic.name
  end

  test "should link to organisations from within the metadata navigation" do
    first_org = create(:organisation, logo_formatted_name: "first")
    second_org = create(:organisation, logo_formatted_name: "second")
    policy = create(:published_policy, organisations: [first_org, second_org])
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_select "#document_organisations a", text: first_org.logo_formatted_name
    assert_select "#document_organisations a", text: second_org.logo_formatted_name
  end

  test "should link to ministers from within the metadata navigation" do
    role = create(:ministerial_role)
    appointment = create(:role_appointment, person: create(:person, forename: "minister-name"), role: role)
    policy = create(:published_policy, ministerial_roles: [appointment.role])
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_select "#document_ministers a.minister", text: "minister-name"
  end

  test "should not apply active class to the parent policy page navigation heading" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    assert_select "section.contextual_info a.active",
      text: policy.title,
      count: 0
  end

  test "should apply active class to the current supporting page navigation heading" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy, title: "This is the active one")
    other_supporting_page = create(:supporting_page, edition: policy, title: "This is an inactive one")

    get :show, policy_id: policy.document, id: supporting_page

    assert_select "section.contextual_info a.active",
      text: supporting_page.title,
      count: 1
    assert_select "section.contextual_info a.active",
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

    assert_select policy_team_selector do
      assert_select "a[href='mailto:policy-team@example.com']", text: 'policy-team@example.com'
    end
  end

  test "show doesn't display the policy team section if the policy isn't associated with a policy team" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)

    get :show, policy_id: policy.document, id: supporting_page

    refute_select policy_team_selector
  end
end
