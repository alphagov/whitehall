# previous content ids (not in publishing api)
# 1638037 => "643dd053-5f82-451f-bcc4-b8b676a80433"
# 1683924 => "e52eaeda-abe6-4b53-aaf9-ef4049ad215c"

{
  1_638_037 => "1daa93ab-a5f0-4043-9177-f6aad84e0d4d",
  1_683_924 => "22443bfa-c8d2-45b0-9827-a3ae42b759b5",
}.each do |id, new_content_id|
  attachment = HtmlAttachment.find_by(id:)
  attachment.update!(content_id: new_content_id) if attachment
end
