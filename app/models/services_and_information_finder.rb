class ServicesAndInformationFinder
  def initialize(organisation, search_client)
    @organisation = organisation
    @search_client = search_client
  end

  def find
    services_and_information_for_organisation
  end

private

  attr_reader :organisation, :search_client

  def services_and_information_for_organisation
    search_client.search(search_query)
  end

  def search_query
    {
      count: "0",
      filter_organisations: [organisation.slug],

      # DID YOU MEAN: Topic?
      # "Policy area" is the newer name for "topic"
      # (https://www.gov.uk/government/topics)
      # "Topic" is the newer name for "specialist sector"
      # (https://www.gov.uk/topic)
      facet_specialist_sectors: "1000,examples:4,example_scope:query,order:value.title",
    }
  end
end
