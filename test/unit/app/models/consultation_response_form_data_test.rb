require "test_helper"

class ConsultationResponseFormDataTest < ActiveSupport::TestCase
  test "should be invalid without a file" do
    consultation_response_form_data = build(:consultation_response_form_data, file: nil)
    assert_not consultation_response_form_data.valid?
  end

  test "should return its consultation's auth_bypass_id" do
    auth_bypass_id = "86385d6a-f918-4c93-96bf-087218a48ced"
    consultation = Consultation.new(id: 1, auth_bypass_id:)
    consultation_participation = build(:consultation_participation, consultation:)
    consultation_response_form = build(:consultation_response_form, consultation_participation:)
    consultation_response_form_data = build(:consultation_response_form_data, consultation_response_form:)

    assert_equal consultation_response_form_data.auth_bypass_ids, [auth_bypass_id]
  end

  test "#all_asset_variants_uploaded? should return true when there is an original asset" do
    consultation_response_form_data = build(:consultation_response_form_data)

    assert consultation_response_form_data.all_asset_variants_uploaded?
  end

  test "#all_asset_variants_uploaded? should return false when there is no asset" do
    consultation_response_form_data = build(:consultation_response_form_data)
    consultation_response_form_data.assets = []

    assert_equal false, consultation_response_form_data.all_asset_variants_uploaded?
  end

  test "#all_asset_variants_uploaded? returns true on update if the new assets have finished uploading" do
    consultation_participation = build(:consultation_participation)
    consultation_response_form = build(:consultation_response_form, consultation_participation:)
    consultation_response_form_data = create(:consultation_response_form_data, consultation_response_form:)
    Sidekiq::Job.clear_all

    filename = "greenpaper.pdf"
    response = { "id" => "http://asset-manager/assets/asset-id", "name" => filename }
    Services.asset_manager.expects(:create_asset).with { |args| args[:file].path =~ /#{filename}/ }.returns(response)

    consultation_response_form_data.update!(
      consultation_response_form_data.attributes.merge(
        file: upload_fixture(filename),
      ),
    )

    AssetManagerCreateAssetWorker.drain

    consultation_response_form_data.reload
    assert consultation_response_form_data.all_asset_variants_uploaded?
  end

  test "#all_asset_variants_uploaded? returns false on update if the new assets have not finished uploading" do
    consultation_participation = build(:consultation_participation)
    consultation_response_form = build(:consultation_response_form, consultation_participation:)
    consultation_response_form_data = create(:consultation_response_form_data, consultation_response_form:)

    consultation_response_form_data.update!(
      consultation_response_form_data.attributes.merge(
        file: upload_fixture("greenpaper.pdf"),
      ),
    )

    assert_not consultation_response_form_data.all_asset_variants_uploaded?
  end
end
