html_attachments = HtmlAttachment.includes(attachable: [:document])
  .joins(<<-SQL)
  INNER JOIN editions ON attachable_id = editions.id
    AND attachable_type = 'Edition'
    AND attachments.type = 'HtmlAttachment'
    AND attachments.deleted = 0
    AND editions.state IN ('published', 'withdrawn')
  SQL


def base_path_for_html_publication(html_publication)
  if html_publication.attachable.is_a?(Publication)
    Whitehall.url_maker.publication_html_attachment_path(publication_id: html_publication.attachable.document.slug, id: html_publication.to_param)
  else
    Whitehall.url_maker.consultation_html_attachment_path(consultation_id: html_publication.attachable.document.slug, id: html_publication.to_param)
  end
end

check = DataHygiene::PublishingApiSyncCheck.new(html_attachments)

check.override_base_path do |record|
  base_path_for_html_publication(record)
end

check.add_expectation("content_id") do |content_store_payload, record|
  content_store_payload["content_id"] == record.content_id
end

check.add_expectation("schema_name") do |content_store_payload, _|
  content_store_payload["schema_name"] == "html_publication"
  content_store_payload["document_type"] == "html_publication"
end

check.add_expectation("base_path") do |content_store_payload, record|
  content_store_payload["base_path"] == base_path_for_html_publication(record)
end

check.add_expectation("title") do |content_store_payload, record|
  content_store_payload["title"] == record.title
end

check.add_expectation("locale") do |content_store_payload, record|
  content_store_payload["locale"] == (record.locale || "en")
end

check.add_expectation("has parent") do |content_store_payload, _record|
  content_store_payload["links"]["parent"].present?
end

check.add_expectation("correct parent") do |content_store_payload, record|
  content_store_payload["links"]["parent"].present? &&
    content_store_payload["links"]["parent"][0]["content_id"] == record.attachable.content_id
end

check.add_expectation("content") do |content_store_payload, _|
  content_store_payload["details"]["body"].present?
  content_store_payload["details"]["headings"].present?
end

check.add_expectation("rendering_app") do |content_store_payload, _|
  content_store_payload["rendering_app"] == "whitehall-frontend"
end

check.perform
