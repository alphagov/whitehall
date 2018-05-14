require 'test_helper'

class Admin::EditionLegacyAssociationsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  test 'should update the edition with the selected legacy tags' do
    @topic = create(:topic)
    @edition = create(:publication, title: 'the edition')


    put :update, params: { edition_id: @edition.id, edition: {
      policy_content_ids: ['', '5d37821b-7631-11e4-a3cb-005056011aef'],
      topic_ids: ['', @topic.id.to_s],
      primary_specialist_sector_tag: 'aaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa',
      secondary_specialist_sector_tags: ['aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeee', 'eeeeeeee-bbbb-cccc-dddd-aaaaaaaaaaaaa']
    }}
    @edition.reload
    assert_equal [@topic.id], @edition.topic_ids
    assert_equal ['5d37821b-7631-11e4-a3cb-005056011aef'], @edition.policy_content_ids
    assert_equal 'aaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa', @edition.primary_specialist_sector_tag
    assert_equal ['aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeee', 'eeeeeeee-bbbb-cccc-dddd-aaaaaaaaaaaaa'],
      @edition.secondary_specialist_sector_tags
  end

  test 'should clear the legacy tags' do
    @topic = create(:topic)
    @edition = create(:publication,
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
