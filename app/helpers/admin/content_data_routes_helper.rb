module Admin::ContentDataRoutesHelper
  def content_data_base_url
    @content_data_base_url ||= "#{Plek.current.external_url_for('content-data')}/content"
  end
end
