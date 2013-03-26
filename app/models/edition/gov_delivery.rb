# Example request
# query: content_type%5B%5D=edition&content_type%5B%5D=policy&organisation%5B%5D=department-for-work-pensions&relevant_to_local_government=true&topic%5B%5D=business-and-enterprise&topic%5B%5D=regulation-reform
# body:  {"title":"Improving the health and safety system","summary":"How the government is improving the health and safety system, making sure it is taken seriously and reducing the burden on business.","link":"/government/policies/improving-the-health-and-safety-system"}

require 'uri'
module Edition::GovDelivery
  extend ActiveSupport::Concern

  included do
    set_callback(:publish, :after) { notify_govuk_delivery }
  end

  def notify_govuk_delivery
    payload = {}
    payload[:organisation] = organisations.map(&:slug)

    if can_be_associated_with_topics? || can_be_related_to_policies?
      payload[:topic] = topics.map(&:slug)
    end

    payload[:content_type] = self.search_format_types
    payload[:relevant_to_local_government] = relevant_to_local_government if can_apply_to_local_government?

    if %w{test development}.include?(Whitehall.platform)
      puts "*" * 80
      puts "query: #{payload.to_param}"
      hash = {title: title, summary: summary, link: public_document_path(self)}.to_json
      puts "body: #{hash}"
    else
      conn = Faraday.new url: Whitehall.gov_delivery_url do |faraday|
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      conn.post do |req|
        req.url "/send-email?#{payload.to_param}"
        req.body = {title: title, summary: summary, link: public_document_path(self)}.to_json
      end
    end
  end
  ####

end