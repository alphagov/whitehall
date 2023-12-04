FactoryBot.define do
  factory :call_for_evidence_response_form_data do
    file { File.open(Rails.root.join("test/fixtures/two-pages.pdf")) }

    after(:build) do |call_for_evidence_response_form_data|
      call_for_evidence_response_form_data.assets << build(:asset, asset_manager_id: "asset_manager_id_original", variant: Asset.variants[:original], filename: call_for_evidence_response_form_data.filename)
    end
  end
end
