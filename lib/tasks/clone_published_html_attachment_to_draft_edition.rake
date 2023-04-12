desc "Clone a documents published HTML attachment to the draft edition"
task :clone_published_html_attachment_to_draft_edition, %i[html_attachment_id] => :environment do |_task, args|
  html_attachment = HtmlAttachment.find(args[:html_attachment_id])

  edition = html_attachment.attachable
  raise "The HTML attachment must belong to a published or superseded edition" if %w[published superseded].exclude?(edition.state)

  latest_edition  = edition.document.latest_edition
  raise "The HTML attachments associated document must have an edition in a pre-published state." if Edition::PRE_PUBLICATION_STATES.exclude?(latest_edition.state)

  latest_edition.attachments << html_attachment.deep_clone
end
