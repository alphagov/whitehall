class StatisticsAnnouncementsController < PublicFacingController
  enable_request_formats(index: [:js])

  def index
    redirect_to_research_and_statistics
  end

private

  def redirect_to_research_and_statistics
    base_path = "#{Plek.new.website_root}/search/research-and-statistics"
    redirect_to("#{base_path}?#{research_and_statistics_query_string}")
  end

  def research_and_statistics_query_string
    {
      content_store_document_type: "upcoming_statistics",
      keywords: params["keywords"],
      level_one_taxon: params["topics"].try(:first),
      organisations: filter_query_array(params["organisations"]),
      public_timestamp: {
        from: params["from_date"],
        to: params["to_date"],
      }.compact.presence,
    }.compact.to_query
  end

  def filter_query_array(arr)
    if arr.respond_to? "reject"
      arr.reject { |v| v == "all" }.compact.presence
    end
  end
end
