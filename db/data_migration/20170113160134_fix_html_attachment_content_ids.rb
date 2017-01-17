content_id_updates = {
  "5ab3d645-3b95-4298-86c4-765834386ef5" => "8da9c1aa-dd3d-441f-8ffe-ac4b5778fc06",
  "1027997f-3529-41f8-a6d2-fc0ec7f1bc1c" => "ee7605dd-47be-47b5-aa76-2c254e8475b4",
  "d5b7db14-7a24-4155-802c-37374d266b20" => "f30254ca-e60c-4242-a3ec-0b41949d4370",
  "2f432a08-334f-4429-845d-f2d4190939af" => "f14d0c64-5dca-4cb4-875b-a5fc390dda60"
}

content_id_updates.each do |old_content_id, new_content_id|
  HtmlAttachment
    .where(content_id: old_content_id)
    .update_all(content_id: new_content_id)
end
