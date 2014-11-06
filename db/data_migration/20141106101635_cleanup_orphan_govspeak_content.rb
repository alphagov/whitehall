existing_ids = HtmlAttachment.pluck(:id)
deleted_count = GovspeakContent.where("html_attachment_id NOT IN (?)", existing_ids).delete_all
puts "#{deleted_count} orphan govspeak content deleted"
