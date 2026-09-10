require "test_helper"

class ConsultationResponseFormDataTest < ActiveSupport::TestCase
  test "should be invalid without a file" do
    consultation_response_form_data = build(:consultation_response_form_data, file: nil)
    assert_not consultation_response_form_data.valid?
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

    AssetManagerCreateAssetJob.drain

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

  test "#attachable returns the parent consultation" do
    consultation = build(:consultation)
    consultation_participation = build(:consultation_participation, consultation:)
    consultation_response_form = build(:consultation_response_form, consultation_participation:)
    consultation_response_form_data = build(:consultation_response_form_data, consultation_response_form:)

    assert_equal consultation, consultation_response_form_data.attachable
  end

  test "#attachable returns a new Edition when there is no consultation" do
    consultation_response_form_data = build(:consultation_response_form_data)

    assert consultation_response_form_data.attachable.new_record?
  end

  test "#replaced? returns false" do
    assert_not build(:consultation_response_form_data).replaced?
  end

  test "#attachments returns the response form when present" do
    consultation_participation = build(:consultation_participation)
    consultation_response_form = build(:consultation_response_form, consultation_participation:)
    consultation_response_form_data = build(:consultation_response_form_data, consultation_response_form:)

    assert_equal [consultation_response_form], consultation_response_form_data.attachments
  end

  test "#attachments returns a null attachment when there is no response form" do
    consultation_response_form_data = build(:consultation_response_form_data)

    assert_instance_of Attachment::Null, consultation_response_form_data.attachments.first
  end
end
