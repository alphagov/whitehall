module Admin::GetInvolvedHelper
  def get_involved_url
    "#{Plek.website_root}/government/get-involved?#{cachebust_url_options.to_query}"
  end
end
