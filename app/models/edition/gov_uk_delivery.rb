# Example request
# query: content_type%5B%5D=edition&content_type%5B%5D=policy&organisation%5B%5D=department-for-work-pensions&relevant_to_local_government=true&topic%5B%5D=business-and-enterprise&topic%5B%5D=regulation-reform
# body:  {"title":"Improving the health and safety system","summary":"How the government is improving the health and safety system, making sure it is taken seriously and reducing the burden on business.","link":"/government/policies/improving-the-health-and-safety-system"}

require 'uri'
module Edition::GovUkDelivery
  extend ActiveSupport::Concern

  included do
    set_callback(:publish, :after) { notify_govuk_delivery }
  end

  def notify_govuk_delivery
    # payload[:relevant_to_local_government] = relevant_to_local_government if can_apply_to_local_government?

    if can_be_associated_with_topics? || can_be_related_to_policies?
      topic_slugs = topics.map(&:slug)
    else
      topic_slugs = []
    end

    org_slugs = organisations.map(&:slug)
    puts "orgs: #{org_slugs.inspect}"
    puts "topics: #{topic_slugs.inspect}"

    tags_args = [[display_type], org_slugs, topic_slugs].reject{ |arr| arr.empty? }
    tags = tags_args.inject(&:product).map(&:flatten)
    puts tags.inspect

  # tags[
  #   "announcements.json?organisation[]=org-slug&topic[]=topic",
  #   "announcements.json?organisation[]=org-slug&topic[]=topic"
  # ]

    payload = {title: title, summary: summary, link: public_document_path(self), tags: tags_args}

    if %w{test development}.include?(Whitehall.platform)
      puts "*" * 80
      puts "payload: #{payload.inspect}"
    else
      conn = Faraday.new url: Whitehall.govuk_delivery_url do |faraday|
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      conn.post do |req|
        req.url "/send-email"
        req.body = payload.to_json
      end
    end
  end
end
