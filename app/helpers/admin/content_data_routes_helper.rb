module Admin::ContentDataRoutesHelper
  def content_data_base_url
    @content_data_base_url ||= "#{Plek.find('content-data')}/content"
  end
end
