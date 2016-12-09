html_attachment_changes = {
  #/government/publications/customs-information-paper-45-2016-information-technology-agreement-ita-rate-changes/customs-information-paper-45-2016-information-technology-agreement-ita-rate-changes
  "b8fb8c66-9edf-42df-b903-46a11de5ae42" => "fff5d183-6c40-4e21-821e-308663da10fb",
  #/government/publications/definitions-to-accompany-our-statistical-releases/companies-house-official-statistics-definitions-to-accompany-statistical-releases
  "6aab6a89-69a0-4f0d-828a-7e2a06deaa0d" => "3d2ec8f3-8b72-4394-a684-c2a40cb24a57",
  #/government/publications/cac-outcome-unite-the-union-lincolnshire-road-car-company-ltd/application-progress
  "a1eebdce-f127-4cfe-a966-db46bc8a6d34" => "544b338b-9ebc-435b-9136-c04b7c951623",
  #/government/publications/sustainability-and-climate-change-opportunities-for-phe/sustainability-and-climate-change-opportunities-for-phe
  "b6f048e8-b486-4451-a5d3-68e6f237bb91" => "cc310b96-388f-4354-874e-85993ebfbf76",
  #/government/publications/cac-outcome-trinity-mirror-printing-ltd/application-closed
  "106ff760-9ea0-4164-a328-9af806b8a6d0" => "49be4ec6-6fdd-44da-9743-d146519010dc",
  #/government/publications/contracts-for-difference/contract-for-difference
  "783cb502-5170-413f-a4eb-701c29fa1a08" => "c9602df6-6b67-4de0-9f83-c639d7ca0332",
  #/government/publications/homes-and-communities-agency-register-of-interests/kevin-parry-register-of-interests
  "7da74881-f5c3-4dc8-becd-4c78a49e6ac8" => "f525956d-c34c-4276-a3b0-b6abc45bcace",
  #/government/publications/company-strike-off-dissolution-and-restoration/strike-off-dissolution-and-restoration
  "9b1afe47-0b5f-4ed3-89a6-059f1c8e1b10" => "1c531c8d-b0e9-40f3-a29a-d0de151ffb98",
  #/government/publications/pr4-3jj-john-smith-environmental-permit-application-advertisement/pr4-3jj-john-smith-environmental-permit-application-advertisement
  "c9336f0e-f8ee-42f0-bf66-38198e1e7ef3" => "d666142d-48c6-407f-9acd-8b1801c251b0",
  #/government/publications/town-bridge-peterborough/town-bridge-peterborough
  "d54e6548-2bda-497e-b0b5-e20cfae71bc3" => "14f06f43-c60b-45e2-ab54-50afee47f06f",
  #/government/publications/st-ives-lock/st-ives-lock
  "d92976b6-60be-4e88-8a1f-0701baaf983c" => "dd93e284-5e3d-4b57-9e60-82b044473fdb",
  #/government/publications/cma-markets-work-recommendations/energy
  "b98e9fe7-b10b-4bd3-ae1c-b0af7d8b80b5" => "50772ee7-b555-44e1-a5d3-c006f232559d"
}

html_attachment_changes.each do |from, to|
  HtmlAttachment.where(content_id: from).each do |attachment|
    attachment.update_column(:content_id, to)
  end
end

document_changes = {
  #/government/publications/defence-information-strategy
  "2096f4e4-32a0-49a7-ab3e-1de35a5f8d75" => "d44e0185-1dd6-42e9-ba79-7eb4d589284b",
  #/government/publications/equality-information-report-2015
  "39a5245d-e1ed-422c-943d-08bb0a241eec" => "53fed749-53ca-476f-9243-da67ea0e8ad7",
  #/government/publications/anti-dumping-duty-measure-ad2138/anti-dumping-duty-measure-ad2138
  "d53aeb37-2841-4e8a-a3f5-4d51f1bd31bd" => "09b404ef-dfad-434f-975f-57d5d21d6b50"
}

document_changes.each do |from, to|
  Document.find_by(content_id: from).try(:update_attributes!, content_id: to)
end
