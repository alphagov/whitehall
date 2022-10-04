module Admin::ContentPublisherRoutesHelper
  def content_publisher_document_summary_url(edition)
    content_id = edition.content_id
    locale = edition.primary_locale

    "#{content_publisher_base_url}/documents/#{content_id}:#{locale}"
  end

private

  def content_publisher_base_url
    Plek.new.external_url_for("content-publisher")
  end
end
