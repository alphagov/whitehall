html_attachments = HtmlAttachment.joins(<<-SQL).includes(attachable: [:document])
  INNER JOIN editions ON attachable_id = editions.id
    AND attachable_type = 'Edition'
    AND attachments.type = 'HtmlAttachment'
    AND editions.state IN ('published', 'withdrawn')
  SQL

check = DataHygiene::PublishingApiSyncCheck.new(html_attachments)

check.override_base_path do |record|
  Whitehall.url_maker.publication_html_attachment_path(publication_id: record.attachable.document.slug, id: record.to_param)
end

check.add_expectation("schema_name") do |content_store_payload, _|
  content_store_payload["schema_name"] == "html_publication"
  content_store_payload["document_type"] == "html_publication"
end

check.add_expectation("base_path") do |content_store_payload, record|
  content_store_payload["base_path"] == Whitehall.url_maker.publication_html_attachment_path(publication_id: record.attachable.document.slug, id: record.to_param)
end

check.add_expectation("title") do |content_store_payload, record|
  content_store_payload["title"] == record.title
end

check.add_expectation("locale") do |content_store_payload, record|
  content_store_payload["locale"] == (record.locale || "en")
end

check.add_expectation("parent") do |content_store_payload, record|
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
