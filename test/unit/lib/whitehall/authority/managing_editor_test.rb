require_relative "authority_test_helper"
require "ostruct"

class ManagingEditorTest < ActiveSupport::TestCase
  def managing_editor(id = 1)
    OpenStruct.new(
      id:,
      gds_editor?: false,
      departmental_editor?: false,
      managing_editor?: true,
      organisation: build(:organisation),
      can_force_publish_anything?: false,
    )
  end

  include AuthorityTestHelper

  test "can create a new document" do
    assert enforcer_for(managing_editor, Document).can?(:create)
  end

  test "can create a new edition" do
    assert enforcer_for(managing_editor, Edition).can?(:create)
  end

  test "can see an edition that is not access limited" do
    assert enforcer_for(managing_editor, normal_edition).can?(:see)
  end

  test "can see an edition that is access limited if it is limited to their organisation" do
    organisation = "organisation"
    user = managing_editor
    user.stubs(:organisation).returns(organisation)
    edition = limited_publication([organisation])
    assert enforcer_for(user, edition).can?(:see)
  end

  test "cannot see an edition that is access limited if it is limited an organisation they don't belong to" do
    organisation1 = "organisation_1"
    organisation2 = "organisation_2"
    user = managing_editor
    user.stubs(:organisation).returns(organisation1)
    edition = limited_publication([organisation2])

    assert_not enforcer_for(user, edition).can?(:see)
  end

  test "cannot do anything to an edition they are not allowed to see" do
    organisation1 = "organisation_1"
    organisation2 = "organisation_2"
    user = managing_editor
    user.stubs(:organisation).returns(organisation1)
    edition = limited_publication([organisation2])
    enforcer = enforcer_for(user, edition)

    Whitehall::Authority::Rules::EditionRules.actions.each do |action|
      assert_not enforcer.can?(action)
    end
  end

  test "can create a new edition of a document that is not access limited" do
    assert enforcer_for(managing_editor, normal_edition).can?(:create)
  end

  test "can make changes to an edition that is not access limited" do
    assert enforcer_for(managing_editor, normal_edition).can?(:update)
  end

  test "can delete an edition that is not access limited" do
    assert enforcer_for(managing_editor, normal_edition).can?(:delete)
  end

  test "can make a fact check request for a edition" do
    assert enforcer_for(managing_editor, normal_edition).can?(:make_fact_check)
  end

  test "can view fact check requests on a edition" do
    assert enforcer_for(managing_editor, normal_edition).can?(:review_fact_check)
  end

  test "can publish an edition" do
    assert enforcer_for(managing_editor, normal_edition).can?(:publish)
  end

  test "can reject an edition" do
    assert enforcer_for(managing_editor, normal_edition).can?(:reject)
  end

  test "can force publish an edition" do
    assert enforcer_for(managing_editor, normal_edition).can?(:force_publish)
  end

  test "cannot publish a scheduled edition" do
    assert_not enforcer_for(managing_editor, scheduled_edition).can?(:publish)
  end

  test "cannot force publish a scheduled edition" do
    assert_not enforcer_for(managing_editor, scheduled_edition).can?(:force_publish)
  end

  test "can force publish a limited access edition outside their org if they can_force_publish_anything?" do
    organisation1 = "organisation_1"
    organisation2 = "organisation_2"
    user = managing_editor
    user.stubs(:organisation).returns(organisation1)
    user.stubs(:can_force_publish_anything?).returns(true)
    edition = limited_publication([organisation2])

    assert enforcer_for(user, edition).can?(:force_publish)
  end

  test "can make editorial remarks" do
    assert enforcer_for(managing_editor, normal_edition).can?(:make_editorial_remark)
  end

  test "can review editorial remarks" do
    assert enforcer_for(managing_editor, normal_edition).can?(:review_editorial_remark)
  end

  test 'can clear the "not reviewed" flag on editions they didn\'t force publish' do
    assert enforcer_for(managing_editor(10), force_published_edition(managing_editor(100))).can?(:approve)
  end

  test 'cannot clear the "not reviewed" flag on editions they did force publish' do
    user = managing_editor
    assert_not enforcer_for(user, force_published_edition(user)).can?(:approve)
  end

  test 'can clear the "not reviewed" flag on editions they did not force schedule' do
    assert enforcer_for(managing_editor(10), force_scheduled_edition(managing_editor(100))).can?(:approve)
  end

  test 'cannot clear the "not reviewed" flag on editions they force scheduled' do
    user = managing_editor
    assert_not enforcer_for(user, force_scheduled_edition(user)).can?(:approve)
  end

  test "can limit access to an edition" do
    assert enforcer_for(managing_editor, normal_edition).can?(:limit_access)
  end

  test "can unpublish an edition" do
    assert enforcer_for(managing_editor, normal_edition).can?(:unpublish)
  end

  test "can unpublish an edition with multiple roles" do
    editor = managing_editor
    editor.send("departmental_editor?=", true)
    editor.send("gds_editor?=", true)
    assert enforcer_for(editor, normal_edition).can?(:unpublish)
  end

  test "cannot reorder cabinet ministers" do
    assert_not enforcer_for(managing_editor, MinisterialRole).can?(:reorder_cabinet_ministers)
  end

  test "cannot administer the sitewide_settings" do
    assert_not enforcer_for(managing_editor, :sitewide_settings_section).can?(:administer)
  end

  test "can manage featured links for their organisation and child organisation" do
    user = managing_editor

    editors_org = user.organisation
    child_org = create(:organisation, parent_organisations: [editors_org])
    other_org = build(:organisation)

    assert enforcer_for(user, editors_org).can?(:manage_featured_links)
    assert enforcer_for(user, child_org).can?(:manage_featured_links)
    assert_not enforcer_for(user, other_org).can?(:manage_featured_links)
  end

  test "can export editions" do
    assert enforcer_for(managing_editor, Edition).can?(:export)
  end

  test "can mark editions as political" do
    assert enforcer_for(managing_editor, normal_edition).can?(:mark_political)
  end

  test "cannot modify historic editions" do
    assert_not enforcer_for(managing_editor, historic_edition).can?(:modify)
  end

  test "cannot publish historic editions" do
    assert_not enforcer_for(managing_editor, historic_edition).can?(:publish)
  end

  test "can create social media accounts" do
    assert enforcer_for(managing_editor, build(:social_media_account)).can?(:create)
  end

  test "can update social media accounts" do
    assert enforcer_for(managing_editor, build(:social_media_account)).can?(:update)
  end

  test "can delete social media accounts" do
    assert enforcer_for(managing_editor, build(:social_media_account)).can?(:delete)
  end
end
