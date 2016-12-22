require 'test_helper'
require 'data_hygiene/policy_tagger'

class PolicyTaggerTest < ActiveSupport::TestCase
  include DataHygiene

  setup do
    @csv_file = Tempfile.new('policy_changes')
    @content_id_1 = policy_area_1["content_id"]
    @content_id_2 = policy_area_2["content_id"]
    @content_id_3 = policy_area_3["content_id"]

    @edition = create(:news_article, policy_content_ids: [@content_id_1])
    @document = @edition.document

    stub_registration
  end

  def tear_down
    @csv_file.unlink
  end

  test "#process - processes the csv file" do
    @csv_file.write("policies_to_remove,policies_to_add,slug\n")
    @csv_file.write("#{@content_id_1},#{@content_id_2} #{@content_id_3},#{@document.slug}")
    @csv_file.rewind

    assert_equal [@content_id_1], @edition.reload.policy_content_ids

    PolicyTagger.process_from_csv(@csv_file.path)

    assert_equal [@content_id_2, @content_id_3], @edition.reload.policy_content_ids

    tear_down
  end

  def stub_registration
    Whitehall::PublishingApi.stubs(:republish_async)
    ServiceListeners::SearchIndexer.any_instance.stubs(:index!)
  end
end
