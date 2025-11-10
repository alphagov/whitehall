# Breakdown of documents to redirect:
#
# There is a whitehall collection which includes two groups
#
# Group - Pledges:
# "Businesses who have signed the Armed Forces Covenant (company names beginning with 1 to 9) dc30fe92-c052-4f47-a1e4-eab8d318a6b4",
# "Businesses who have signed the Armed Forces Covenant (company names beginning with A) 5ebb2099-7631-11e4-a3cb-005056011aef",
# "Businesses who have signed the Armed Forces Covenant (company names beginning with B) 78d454a6-e959-4804-9874-ac4c181fd14c",
# "Businesses who have signed the Armed Forces Covenant (company names beginning with C) 5f65b92f-7631-11e4-a3cb-005056011aef",
# "Businesses who have signed the Armed Forces Covenant  (company names beginning with D) efa5ba20-2073-4e18-8748-6349f2bf0383",
# "Businesses who have signed the Armed Forces Covenant (company names beginning with E) 5fd954f4-7631-11e4-a3cb-005056011aef",
# "Businesses who have signed the Armed Forces Covenant (company names beginning with F) e2bc228e-e675-4269-9871-bda0fdda3cde",
# "Businesses who have signed the Armed Forces Covenant (company names beginning with G) 8ecf81a4-b87c-4507-803a-fea75c336ede",
# "Businesses who have signed the Armed Forces Covenant (company names beginning with H to J) 5faa235a-7631-11e4-a3cb-005056011aef",
# "Businesses who have signed the Armed Forces Covenant (company names beginning with K) 5faa23aa-7631-11e4-a3cb-005056011aef",
# "Businesses who have signed the Armed Forces Covenant (company names beginning with L) 67c92acb-7a04-4db0-b648-a15bd5980d98",
# "Businesses who have signed the Armed Forces Covenant (company names beginning with M) fb822b13-336d-4b02-bb8a-bb1a2e6ac648",
# "Businesses who have signed the Armed Forces Covenant (company names beginning with N to P) 5faa23f6-7631-11e4-a3cb-005056011aef",
# "Businesses who have signed the Armed Forces Covenant (company names beginning with Q) 5faa2ccd-7631-11e4-a3cb-005056011aef",
# "Businesses who have signed the Armed Forces Covenant (company names beginning with R) 51959543-9fff-4768-a610-4af3e978378a",
# "Businesses who have signed the Armed Forces Covenant (company names beginning with S) 5faa3004-7631-11e4-a3cb-005056011aef",
# "Businesses who have signed the Armed Forces Covenant (company names beginning with T) b944addf-9f0d-47a1-9126-78adb45cd055",
# "Businesses who have signed the Armed Forces Covenant (company names with U to Z) 5fa8a97a-7631-11e4-a3cb-005056011aef"
#
# Group - Search:
# "Search for businesses who have signed the Armed Forces Covenant a0396ea3-2acd-4f1a-9294-86bdc4a9b5e7"
# We are making a copy of the ods file for our records before we unpublish it.
#
# Plus another document outside that collection:
# "Businesses who have signed the Armed Forces Covenant (company names beginning with O)" "e658bfdc-c1fc-4804-9b79-220d0162d82c"
#
# Plus another guidance including a pdf that needs to be redirected:
# Employers who have signed the Armed Forces Covenant since 1 January 2016 ca0a4f39-5ed0-474a-ae72-50afdccd357c
#
# We are leaving the collection itself live to review the content. https://www.gov.uk/government/collections/armed-force-corporate-covenant-signed-pledges

unpublishing_params = { unpublishing_reason_id: UnpublishingReason::CONSOLIDATED_ID, alternative_url: "https://www.gov.uk/armed-forces-covenant-businesses", explanation: "Redirect to armed forces covenant businesses finder" }

content_ids = %w[dc30fe92-c052-4f47-a1e4-eab8d318a6b4
                 5ebb2099-7631-11e4-a3cb-005056011aef
                 78d454a6-e959-4804-9874-ac4c181fd14c
                 5f65b92f-7631-11e4-a3cb-005056011aef
                 efa5ba20-2073-4e18-8748-6349f2bf0383
                 5fd954f4-7631-11e4-a3cb-005056011aef
                 e2bc228e-e675-4269-9871-bda0fdda3cde
                 8ecf81a4-b87c-4507-803a-fea75c336ede
                 5faa235a-7631-11e4-a3cb-005056011aef
                 5faa23aa-7631-11e4-a3cb-005056011aef
                 67c92acb-7a04-4db0-b648-a15bd5980d98
                 fb822b13-336d-4b02-bb8a-bb1a2e6ac648
                 5faa23f6-7631-11e4-a3cb-005056011aef
                 5faa2ccd-7631-11e4-a3cb-005056011aef
                 51959543-9fff-4768-a610-4af3e978378a
                 5faa3004-7631-11e4-a3cb-005056011aef
                 b944addf-9f0d-47a1-9126-78adb45cd055
                 5fa8a97a-7631-11e4-a3cb-005056011aef
                 a0396ea3-2acd-4f1a-9294-86bdc4a9b5e7
                 e658bfdc-c1fc-4804-9b79-220d0162d82c
                 ca0a4f39-5ed0-474a-ae72-50afdccd357c]

content_ids.each do |content_id|
  edition = Document.find_by_content_id(content_id).live_edition
  unpublisher = Whitehall.edition_services.unpublisher(
    edition,
    unpublishing: unpublishing_params,
  )
  unpublisher.perform!
rescue StandardError => e
  puts "Failed to unpublish #{content_id} due to: #{e.message}"
end
