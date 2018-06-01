require 'test_helper'
require 'gds_api/test_helpers/publishing_api_v2'

class Taxonomy::SyncBrexitPoliciesTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  def class_instance
    Taxonomy::SyncBrexitPolicies.new
  end

  def taxon_content_ids
    @taxon_content_ids ||= [SecureRandom.uuid, SecureRandom.uuid]
  end

  def create_brexit_policy_edition
    FactoryBot.create(:edition, :published, :with_policy_edition, policy_content_id: Taxonomy::SyncBrexitPolicies::BREXIT_POLICY_ID)
  end

  def has_links_for_content_ids(edition, taxons, version = 1)
    publishing_api_has_links_for_content_ids(
      edition.content_id =>
      { "links" =>
       { "taxons" => taxons },
         "version" => version }
    )
  end

  test 'if there is not content with brexit policies tagged' do
    publishing_api_has_links_for_content_ids({})
    Services.publishing_api.expects(:patch_links).never
    class_instance.call
  end

  test 'if there is content with brexit policies tagged that is already linked to brexit taxon' do
    edition = create_brexit_policy_edition

    has_links_for_content_ids(edition, Taxonomy::SyncBrexitPolicies::BREXIT_TAXON_ID)

    Services.publishing_api.expects(:patch_links).never
    class_instance.call
  end

  test 'if there is content with brexit policies tagged that is not linked to brexit taxon' do
    edition = create_brexit_policy_edition

    has_links_for_content_ids(edition, taxon_content_ids)

    stub_any_publishing_api_patch_links
    class_instance.call

    assert_publishing_api_patch_links(
      edition.content_id,
      'links' => {
        'taxons' => taxon_content_ids + [Taxonomy::SyncBrexitPolicies::BREXIT_TAXON_ID],
      },
      'previous_version' => 1
    )
  end

  test 'if the version id from get_content_ids does not match the previous version when calling patch links' do
    edition = create_brexit_policy_edition

    has_links_for_content_ids(edition, taxon_content_ids)

    stub_any_publishing_api_patch_links.and_raise(GdsApi::HTTPConflict).times(2).then.to_return(body: '{}')
    assert_nothing_raised do
      class_instance.call
    end

    stub_any_publishing_api_patch_links.and_raise(GdsApi::HTTPConflict).times(3).then.to_return(body: '{}')
    assert_raises GdsApi::HTTPConflict do
      class_instance.call
    end
  end
end
