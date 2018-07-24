require 'test_helper'

class Admin::EditionLegacyAssociationsControllerTest < ActionController::TestCase
  include Admin::EditionRoutesHelper
  include PolicyTaggingHelpers

  should_be_an_admin_controller

  view_test 'should render edit form correctly populated' do
    publishing_api_has_linkables(
      [
        {
          'content_id' => 'WELLS',
          'internal_name' => 'Oil and Gas / Wells',
          'publication_state' => 'published',
        },
        {
          'content_id' => 'FIELDS',
          'internal_name' => 'Oil and Gas / Fields',
          'publication_state' => 'published',
        },
        {
          'content_id' => 'OFFSHORE',
          'internal_name' => 'Oil and Gas / Offshore',
          'publication_state' => 'published',
        },
        {
          'content_id' => 'DISTILL',
          'internal_name' => 'Oil and Gas / Distillation',
          'publication_state' => 'draft',
        },
      ],
      document_type: 'topic'
    )
    @topic = create(:topic)
    @edition = create(
      :publication,
      title: 'the edition',
      policy_content_ids: ['5d37821b-7631-11e4-a3cb-005056011aef'],
      topic_ids: [@topic.id.to_s],
      primary_specialist_sector_tag: 'WELLS',
      secondary_specialist_sector_tags: %w(FIELDS OFFSHORE)
    )
    get :edit, params: { edition_id: @edition.id }
    assert_select "#edition_policy_content_ids option[value='5d37821b-7631-11e4-a3cb-005056011aef'][selected='selected']", '2012 olympic and paralympic legacy'
    assert_select "#edition_policy_content_ids option[value='#{policy_1[:content_id]}']", policy_1[:title]
    assert_select "select[name='edition[policy_content_ids][]'][data-track-category='taxonSelectionPolicies']"
    assert_select "select[name='edition[policy_content_ids][]'][data-track-label='/government/admin/editions/#{@edition.id}/legacy_associations/edit']"
    refute_select "#edition_policy_content_ids option[value='#{policy_1[:content_id]}'][selected='selected']"
    assert_select "#edition_topic_ids option[value='#{@topic.id}'][selected='selected']", @topic.name
    assert_select "#edition_primary_specialist_sector_tag option[value='WELLS'][selected='selected']", 'Oil and Gas: Wells'
    assert_select "#edition_secondary_specialist_sector_tags option[value='FIELDS'][selected='selected']", 'Oil and Gas: Fields'
    assert_select "#edition_secondary_specialist_sector_tags option[value='OFFSHORE'][selected='selected']", 'Oil and Gas: Offshore'
    assert_select "#edition_secondary_specialist_sector_tags option[value='DISTILL']", 'Oil and Gas: Distillation (draft)'
    refute_select "#edition_secondary_specialist_sector_tags option[value='DISTILL'][selected='selected']"
  end

  view_test 'should not render the policy drop-down if not supported' do
    @edition = create(:corporate_information_page, title: "corp info")
    get :edit, params: { edition_id: @edition.id }
    refute_select "#edition_policy_content_ids"
  end

  view_test 'should not render the policy area drop-down if not supported' do
    @edition = create(:corporate_information_page, title: "corp info")
    get :edit, params: { edition_id: @edition.id }
    refute_select "#edition_topic_ids"
  end

  view_test 'should render the cancel button back to the admin page' do
    @edition = create(:publication)
    get :edit, params: { edition_id: @edition.id }
    assert_select ".form-actions a:contains('cancel')[href='#{@controller.admin_edition_path(@edition)}']"
  end

  view_test 'should render the cancel button back to the tags page' do
    @edition = create(:publication)
    get :edit, params: { edition_id: @edition.id, return: 'tags' }
    assert_select ".form-actions a:contains('cancel')[href='#{@controller.edit_admin_edition_tags_path(@edition)}']"
  end

  view_test 'should render the cancel button back to the edit page' do
    @edition = create(:publication)
    get :edit, params: { edition_id: @edition.id, return: 'edit' }
    assert_select ".form-actions a:contains('cancel')[href='#{@controller.edit_admin_edition_path(@edition)}']"
  end

  test 'should update the edition with the selected legacy tags' do
    @topic = create(:topic)
    @edition = create(:publication, title: 'the edition')


    put :update, params: { edition_id: @edition.id,
      edition: {
        policy_content_ids: ['', '5d37821b-7631-11e4-a3cb-005056011aef'],
        topic_ids: ['', @topic.id.to_s],
        primary_specialist_sector_tag: 'aaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa',
        secondary_specialist_sector_tags: ['aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeee', 'eeeeeeee-bbbb-cccc-dddd-aaaaaaaaaaaaa']
      } }
    @edition.reload
    assert_equal [@topic.id], @edition.topic_ids
    assert_equal ['5d37821b-7631-11e4-a3cb-005056011aef'], @edition.policy_content_ids
    assert_equal 'aaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa', @edition.primary_specialist_sector_tag
    assert_equal ['aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeee', 'eeeeeeee-bbbb-cccc-dddd-aaaaaaaaaaaaa'],
      @edition.secondary_specialist_sector_tags
  end

  test 'should clear the legacy tags' do
    @topic = create(:topic)
    @edition = create(
      :publication,
      title: 'the edition',
      policy_content_ids: ['5d37821b-7631-11e4-a3cb-005056011aef'],
      topic_ids: [@topic.id.to_s],
      primary_specialist_sector_tag: 'aaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa',
      secondary_specialist_sector_tags: ['aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeee', 'eeeeeeee-bbbb-cccc-dddd-aaaaaaaaaaaaa']
    )


    put :update, params: { edition_id: @edition.id, edition: {
      policy_content_ids: [''],
      topic_ids: [''],
      primary_specialist_sector_tag: '',
      secondary_specialist_sector_tags: ['']
    } }
    @edition.reload
    assert_equal [], @edition.topic_ids
    assert_equal [], @edition.policy_content_ids
    assert_nil @edition.primary_specialist_sector_tag
    assert_equal [],
      @edition.secondary_specialist_sector_tags
  end
end
