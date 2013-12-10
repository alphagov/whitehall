require "test_helper"

class SupportingPagesControllerTest < ActionController::TestCase
  include PublicDocumentRoutesHelper

  test "index redirects to the first supporting page" do
    policy = create(:published_policy)
    supporting_page_1 = create(:published_supporting_page, title: "supporting-page-1", related_policies: [policy])
    supporting_page_2 = create(:published_supporting_page, title: "supporting-page-2", related_policies: [policy])

    get :index, policy_id: policy.document

    assert_redirected_to policy_supporting_page_path(policy.document, supporting_page_1.document)
  end

  test "index should return a 404 response if there aren't any supporting pages" do
    policy = create(:published_policy)
    get :index, policy_id: policy.document
    assert_response 404
  end

  view_test "show displays the date that the policy was updated" do
    policy = create(:published_policy)
    supporting_page = create(:published_supporting_page, related_policies: [policy])

    get :show, policy_id: policy.document, id: supporting_page.document

    assert_select ".published-at[title=#{policy.public_timestamp.iso8601}]"
  end

  view_test "show includes the main policy navigation" do
    policy = create(:published_policy)
    supporting_page = create(:published_supporting_page, related_policies: [policy])

    get :show, policy_id: policy.document, id: supporting_page.document

    assert_select ".activity-navigation" do
      assert_select "a[href='#{policy_path(policy.document)}']"
      assert_select "a[href='#{policy_supporting_pages_path(policy.document)}']"
    end
  end

  view_test "show adds the current class to the supporting pages link in the policy navigation" do
    policy = create(:published_policy)
    supporting_page = create(:published_supporting_page, related_policies: [policy])

    get :show, policy_id: policy.document, id: supporting_page.document

    assert_select ".activity-navigation a.current[href='#{policy_supporting_pages_path(policy.document)}']"
  end

  view_test "shows the body using govspeak markup" do
    policy = create(:published_policy)
    supporting_page = create(:published_supporting_page, related_policies: [policy], body: "body-in-govspeak")
    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :show, policy_id: policy.document, id: supporting_page.document
    end

    assert_select ".body", text: "body-in-html"
  end

  test "doesn't show supporting page if parent isn't published" do
    policy = create(:draft_policy)
    supporting_page = create(:published_supporting_page, related_policies: [policy])

    get :show, policy_id: policy.document, id: supporting_page.document

    assert_response :not_found
  end

  view_test "should show inapplicable nations" do
    policy = create(:published_policy)
    northern_ireland_inapplicability = policy.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://northern-ireland.com/")
    scotland_inapplicability = policy.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://scotland.com")
    supporting_page = create(:published_supporting_page, related_policies: [policy])

    get :show, policy_id: policy.document, id: supporting_page.document

    assert_select inapplicable_nations_selector, "England and Wales (see policy for Northern Ireland and Scotland)" do
      assert_select "a[href='http://northern-ireland.com/']"
    end
  end

  view_test "should not explicitly say that policy applies to the whole of the UK" do
    policy = create(:published_policy)
    supporting_page = create(:published_supporting_page, related_policies: [policy])

    get :show, policy_id: policy.document, id: supporting_page.document

    refute_select inapplicable_nations_selector
  end

  view_test "show lists supporting pages when there are some" do
    policy = create(:published_policy)
    first_supporting_page = create(:published_supporting_page, related_policies: [policy])
    second_supporting_page = create(:published_supporting_page, related_policies: [policy])
    supporting_page = create(:published_supporting_page, related_policies: [policy])

    get :show, policy_id: policy.document, id: supporting_page.document

    assert_select ".contextual-info nav.supporting-pages" do
      assert_select "a[href='#{policy_supporting_page_path(policy.document, first_supporting_page.document)}']", text: first_supporting_page.title
      assert_select "a[href='#{policy_supporting_page_path(policy.document, second_supporting_page.document)}']", text: second_supporting_page.title
    end
  end

  test "should display the published policy" do
    policy = create(:published_policy)
    draft_policy = policy.create_draft(create(:user))

    supporting_page = create(:published_supporting_page, related_policies: [policy])

    get :show, policy_id: draft_policy.document, id: supporting_page.document

    assert_response :success
    assert_equal policy, assigns(:policy)
  end

  test "should display the published supporting page" do
    policy = create(:published_policy)

    supporting_page = create(:published_supporting_page, related_policies: [policy])
    draft_supporting_page = supporting_page.create_draft(create(:user))

    get :show, policy_id: policy.document, id: draft_supporting_page.document

    assert_response :success
    assert_equal supporting_page, assigns(:supporting_page)
  end

  view_test "should link to topics" do
    first_topic = create(:topic)
    second_topic = create(:topic)
    policy = create(:published_policy, topics: [first_topic, second_topic])
    supporting_page = create(:published_supporting_page, related_policies: [policy])

    get :show, policy_id: policy.document, id: supporting_page.document

    assert_select ".document-topics a", text: first_topic.name
    assert_select ".document-topics a", text: second_topic.name
  end

  view_test "should link to organisations from within the metadata navigation" do
    first_org = create(:organisation)
    second_org = create(:organisation)
    policy = create(:published_policy, organisations: [first_org, second_org])
    supporting_page = create(:published_supporting_page, related_policies: [policy])

    get :show, policy_id: policy.document, id: supporting_page.document

    assert_select_object first_org do
      assert_select "a[href='#{organisation_path(first_org)}']"
    end
    assert_select_object second_org do
      assert_select "a[href='#{organisation_path(second_org)}']"
    end
  end

  view_test "should link to ministers from within the metadata navigation" do
    role = create(:ministerial_role)
    appointment = create(:role_appointment, person: create(:person, forename: "minister-name"), role: role)
    policy = create(:published_policy, ministerial_roles: [appointment.role])
    supporting_page = create(:published_supporting_page, related_policies: [policy])

    get :show, policy_id: policy.document, id: supporting_page.document

    assert_select ".document-ministerial-roles a", text: "minister-name"
  end

  view_test "should not apply active class to the parent policy page navigation heading" do
    policy = create(:published_policy)
    supporting_page = create(:published_supporting_page, related_policies: [policy])

    get :show, policy_id: policy.document, id: supporting_page.document

    assert_select "section.contextual-info .active",
      text: policy.title,
      count: 0
  end

  view_test "should apply active class to the current supporting page navigation heading" do
    policy = create(:published_policy)
    supporting_page = create(:published_supporting_page, related_policies: [policy], title: "This is the active one")
    other_supporting_page = create(:published_supporting_page, related_policies: [policy], title: "This is an inactive one")

    get :show, policy_id: policy.document, id: supporting_page.document

    assert_select "section.contextual-info .active",
      text: supporting_page.title,
      count: 1
    assert_select "section.contextual-info .active",
      text: other_supporting_page.title,
      count: 0
  end

  view_test "should use supporting page title as page title" do
    policy = create(:published_policy)
    supporting_page = create(:published_supporting_page, related_policies: [policy])

    get :show, policy_id: policy.document, id: supporting_page.document

    assert_select "title", text: Regexp.new(supporting_page.title)
  end

  view_test "should use supporting page title as h1" do
    policy = create(:published_policy)
    supporting_page = create(:published_supporting_page, related_policies: [policy])

    get :show, policy_id: policy.document, id: supporting_page.document

    assert_select "h1", text: supporting_page.title
  end

  view_test "show displays the policy team responsible for this policy" do
    policy_team = create(:policy_team, email: 'policy-team@example.com')
    policy = create(:published_policy, policy_teams: [policy_team])
    supporting_page = create(:published_supporting_page, related_policies: [policy])

    get :show, policy_id: policy.document, id: supporting_page.document

    assert_select ".document-policy-team a[href='#{policy_team_path(policy_team)}']", text: 'policy-team-name'

  end

  view_test "show doesn't display the policy team section if the policy isn't associated with a policy team" do
    policy = create(:published_policy)
    supporting_page = create(:published_supporting_page, related_policies: [policy])

    get :show, policy_id: policy.document, id: supporting_page.document

    refute_select policy_team_selector
  end

  view_test "shows correct sub navigation when viewing supporting details" do
    policy = create(:published_policy)
    supporting_page = create(:published_supporting_page, related_policies: [policy])

    get :show, policy_id: policy.document, id: supporting_page.document

    assert_select '.activity-navigation' do
      assert_select "a[href='#{policy_path(policy.document)}']"
      assert_select "a[href='#{policy_supporting_pages_path(policy.document)}']"
    end
  end

  view_test "shows activity link when viewing supporting details" do
    policy = create(:published_policy)
    supporting_page = create(:published_supporting_page, related_policies: [policy])
    speech = create(:published_speech, related_editions: [policy])

    get :show, policy_id: policy.document, id: supporting_page.document

    assert_select '.activity-navigation' do
      assert_select "a[href='#{policy_path(policy.document)}']"
      assert_select "a[href='#{policy_supporting_pages_path(policy.document)}']"
      assert_select "a[href='#{activity_policy_path(policy.document)}']"
    end
  end

  view_test "shows inline attachments when viewing supporting details" do
    policy = create(:published_policy)
    supporting_page = create(:published_supporting_page, related_policies: [policy], body: "!@1", attachments: [
      attachment = build(:file_attachment)
    ])

    get :show, policy_id: policy.document, id: supporting_page.document

    assert_select ".attachment" do
      assert_select ".title", text: attachment.title
    end
  end

  test "the format name is being set to 'policy' on the detail tab" do
    policy = create(:published_policy)
    supporting_page = create(:published_supporting_page, related_policies: [policy])

    get :show, policy_id: policy.document, id: supporting_page.document

    assert_equal "policy", response.headers["X-Slimmer-Format"]
  end

  test "#show redirects if there's been a slug change" do
    policy = create(:published_policy)
    supporting_page = create(:published_supporting_page, related_policies: [policy])
    SupportingPageRedirect.create!(policy_document: policy.document,
                                   supporting_page_document: supporting_page.document,
                                   original_slug: "an-old-slug")

    get :show, policy_id: policy.document, id: "an-old-slug"

    assert_response :redirect
    assert_redirected_to policy_supporting_page_path(policy.document, supporting_page.document)
  end
end
