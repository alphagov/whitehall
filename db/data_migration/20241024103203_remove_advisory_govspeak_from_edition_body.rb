CONTENT_CONTAINING_ADVISORY_GOVSPEAK = %w[ae74f681-0eac-4de0-bedc-b4c1703ba5f5
                                          06a0dc8c-3e2a-46fb-ac4c-655ffd7f0591
                                          133d6a44-b47d-4698-8b89-033d4a73e19d
                                          e61139a5-ad01-4ab7-bfb1-719e41e8894a
                                          1c84cb91-e607-46a5-abb2-6cc4eb206666
                                          de6b61eb-a4b9-4d73-a577-84637ad51233
                                          0ce9a360-cd01-4188-993d-91ac80885a95
                                          e5a4fc6a-dbc7-4061-b93e-f226aa1d2775
                                          1594fbb4-6d9f-4c4e-9d5e-c318e6ab46f2
                                          7f254eb4-57ea-4044-8236-4964d9d19e19
                                          aba62e67-b9b7-487f-98b8-4f2a9dcb8759
                                          ba7d1732-962b-4685-aa47-0b2d303c5b7b
                                          461c089f-746e-4918-a987-e4bd80b9a608
                                          bcae8bb2-f364-4436-8b42-e9926b55254a
                                          9711f631-4056-49bb-87b9-f65b47fd7368
                                          329e94f5-9105-453f-8708-d41582eb9301
                                          62a6b167-120b-4197-be3c-bf24f1cef129
                                          965bc1a6-22e8-4d6c-87e3-573e1a71ce24
                                          bea7ebde-98a8-439f-a3c8-2ba688a72de2
                                          2c355840-93c0-49f6-9c3a-92a7f1798716
                                          7e34d4ae-2236-4fae-9d7d-9262bcfb2186
                                          6bdd03c6-cbb6-4996-b341-27a9a7d313be
                                          d8100dcc-93a9-4c0a-b7ac-c97ef393dcd5
                                          4e2eca0c-6d23-4482-af26-763a248eeadd
                                          1d4cdc27-2575-494d-bd9e-61b6990b5647
                                          377b8abf-10d0-45fa-a7b2-9d2b10d70a01
                                          433f8123-b314-4154-9a7d-6309fcadb0b7
                                          b7beb9ed-db49-4aec-9d28-dcab1a566886
                                          f4e5f66d-e758-4f1b-a58f-c3d6f27607a1
                                          689b56c4-5799-4407-8e62-a5384fe8e41b
                                          9d28e1d7-9a82-4dbc-8879-2f675b42902b
                                          0147506d-2355-415a-960b-d0d2fd975af6
                                          8f9e4a1e-32d4-4f42-bf5a-210fe99d82c2
                                          adda2cc0-e956-4912-ad07-10f55151c182
                                          6407ed1c-f94c-4a36-ae00-3730bf9b0e51
                                          a3fabc0d-b13f-41c1-83ef-153e00a98857
                                          39713a34-804a-4df7-9aa9-4ff99a154b06
                                          9a6c004f-9222-4f50-8632-3008c8ad9642
                                          ed5f47f2-c921-4467-8f5d-12454c2d2302
                                          49bed7ae-88d2-402f-b8d5-da56087b7418
                                          0d6533f6-e286-4a25-bb28-4f199421bd80
                                          663468d5-af04-4ca5-86f6-5571b88cf2cd
                                          449d7c17-09ce-4c2f-a8c2-429e2e7cb3d4
                                          574b3a9e-17d5-48b8-aa9a-ecd7dd701659
                                          24f73581-403d-4666-8e9a-e0dc89ec4787
                                          f970dc49-f6f5-4090-ba74-df97c14292c3
                                          2a92cdaf-7598-4072-b21b-6a848cd111c7
                                          25f89135-8d92-463b-8f6b-5c0239e92404
                                          7508f916-ab41-4330-8206-255112f2d266
                                          42ca5dc8-cae3-451f-a18f-bd16f04c9968
                                          479afda5-4b08-47a3-8b49-00f4947c2e57
                                          4a8190cf-1154-4285-b17e-110061d66d62
                                          fe409669-acf1-40df-9ec9-bfc11f9665be
                                          ab66c992-df81-40df-8c32-f44b8a7c37cc
                                          b0425678-6958-4792-8c81-deaea92c4a2a
                                          edb03574-d967-4b25-a6c4-ac461eabc4ed
                                          ab4ee797-03c1-40b3-9633-ff2684b2af39
                                          05f5caf3-4566-478c-8528-fd43460a0c63
                                          80caf789-25b2-4dd9-8387-49f1b5163958
                                          88ba394b-045c-4004-88ff-65e83e9ff775
                                          484887bf-e7d8-45d5-b080-5088aeef5876
                                          f6753ae2-fb80-4111-b91f-4700c2e3d863
                                          f1aefd78-5716-49f1-a353-a0b48a016650].freeze

# CONTENT_CONTAINING_ADVISORY_GOVSPEAK.each do |content_id|
#   document = Document.find_by(content_id:)

#   slug = nil
#   body = nil

#   if document
#     edition = document.latest_edition

#     if edition
#       slug = document.slug
#       body = edition.body
#     else
#       puts "No edition found for document with content_id: #{content_id}"
#       unfound_docs << content_id
#       next
#     end
#   else
#     attachment = Attachment.find_by(content_id:)

#     if attachment
#       slug = attachment.slug
#       body = attachment.body
#     else
#       puts "No document or attachment found for content_id: #{content_id}"
#       unfound_docs << content_id
#       next
#     end
#   end

#   puts slug
#   matches = body.scan(/(^@[\s\S]*?(?:@)?)(?=(?:^\$CTA|\r?\n\r?\n|^@|$))/m)

#   if matches.any?
#     puts "Matches found: #{matches.size}"
#     puts matches
#     all_matches << "#{matches} would be changed for #{slug}"
#   else
#     puts "No matches found"
#     all_matches << "No matches found for #{slug}"
#   end
# end

unfound_docs = []

CONTENT_CONTAINING_ADVISORY_GOVSPEAK.each do |content_id|
  record = Document.find_by(content_id:) || Attachment.find_by(content_id:)

  unless record
    puts "No document or attachment found for content_id: #{content_id}"
    unfound_docs << content_id
    next
  end

  slug = record.slug
  body = record.body

  puts "Processing #{slug}"

  # Probably explain this
  matches = body.scan(/(^@)([\s\S]*?)(@?)(?=(?:^\$CTA|\r?\n\r?\n|^@|$))/m)

  next unless matches.any?

  puts "Matches found: #{matches.size}"

  new_body = body.gsub(/(^@)([\s\S]*?)(@?)(?=(?:^\$CTA|\r?\n\r?\n|^@|$))/m) do
    content = Regexp.last_match(1)
    "^#{content}^"
  end

  if new_body != body
    record.update!(body: new_body)
    puts "Modified body for #{slug}"
  end
end

puts unfound_docs
