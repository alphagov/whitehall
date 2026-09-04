require "test_helper"

class CallForEvidenceResponseFormDataTest < ActiveSupport::TestCase
  test "should be invalid without a file" do
    call_for_evidence_response_form_data = build(:call_for_evidence_response_form_data, file: nil)
    assert_not call_for_evidence_response_form_data.valid?
  end

  test "#all_asset_variants_uploaded? should return true when there is an original asset" do
    call_for_evidence_response_form_data = build(:call_for_evidence_response_form_data)

    assert call_for_evidence_response_form_data.all_asset_variants_uploaded?
  end

  test "#all_asset_variants_uploaded? should return false when there is no asset" do
    call_for_evidence_response_form_data = build(:call_for_evidence_response_form_data)
    call_for_evidence_response_form_data.assets = []

    assert_equal false, call_for_evidence_response_form_data.all_asset_variants_uploaded?
  end

  test "#all_asset_variants_uploaded? returns true on update if the new assets have finished uploading" do
    call_for_evidence_participation = build(:call_for_evidence_participation)
    call_for_evidence_response_form = build(:call_for_evidence_response_form, call_for_evidence_participation:)
    call_for_evidence_response_form_data = create(:call_for_evidence_response_form_data, call_for_evidence_response_form:)
    Sidekiq::Job.clear_all

    filename = "greenpaper.pdf"
    response = { "id" => "http://asset-manager/assets/asset-id", "name" => filename }
    Services.asset_manager.expects(:create_asset).with { |args| args[:file].path =~ /#{filename}/ }.returns(response)

    call_for_evidence_response_form_data.update!(
      call_for_evidence_response_form_data.attributes.merge(
        file: upload_fixture(filename),
      ),
    )

    AssetManagerCreateAssetJob.drain

    call_for_evidence_response_form_data.reload
    assert call_for_evidence_response_form_data.all_asset_variants_uploaded?
  end

  test "#all_asset_variants_uploaded? returns false on update if the new assets have not finished uploading" do
    call_for_evidence_participation = build(:call_for_evidence_participation)
    call_for_evidence_response_form = build(:call_for_evidence_response_form, call_for_evidence_participation:)
    call_for_evidence_response_form_data = create(:call_for_evidence_response_form_data, call_for_evidence_response_form:)

    call_for_evidence_response_form_data.update!(
      call_for_evidence_response_form_data.attributes.merge(
        file: upload_fixture("greenpaper.pdf"),
      ),
    )

    assert_not call_for_evidence_response_form_data.all_asset_variants_uploaded?
  end

  test "#attachable returns the parent call for evidence" do
    call_for_evidence = build(:call_for_evidence)
    call_for_evidence_participation = build(:call_for_evidence_participation, call_for_evidence:)
    call_for_evidence_response_form = build(:call_for_evidence_response_form, call_for_evidence_participation:)
    call_for_evidence_response_form_data = build(:call_for_evidence_response_form_data, call_for_evidence_response_form:)

    assert_equal call_for_evidence, call_for_evidence_response_form_data.attachable
  end

  test "#attachable returns a new Edition when there is no call for evidence" do
    call_for_evidence_response_form_data = build(:call_for_evidence_response_form_data)

    assert call_for_evidence_response_form_data.attachable.new_record?
  end
end
