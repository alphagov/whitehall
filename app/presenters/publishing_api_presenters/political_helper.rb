module PublishingApiPresenters::PoliticalHelper
private

  def government
    gov = item.government
    return nil unless gov
    {
      title: gov.name,
      slug: gov.slug,
      current: gov.current?
    }
  end

  def political_details
    {
      political: item.political?,
      government: government
    }
  end
end
