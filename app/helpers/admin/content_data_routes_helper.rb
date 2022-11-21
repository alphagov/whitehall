module Admin::ContentDataRoutesHelper
  def content_data_home_url
    @content_data_home_url ||= "#{content_data_base_url}/content"
  end

  def content_data_page_data_url(edition)
    "#{content_data_base_url}/metrics#{public_document_path(edition)}"
  end

private

  def content_data_base_url
    Plek.external_url_for("content-data")
  end
end
