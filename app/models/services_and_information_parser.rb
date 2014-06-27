class ServicesAndInformationParser
  def initialize(content)
    @content = content
  end

  def parse
    parsed_content
  end

private

  attr_reader :content

  def parsed_content
    content_groups.map do |group|
      {
        title: group[:value][:title],
        examples: group[:value][:example_info][:examples],
        document_count: group[:value][:example_info][:total],
        subsector_link: group[:value][:slug],
      }
    end
  end

  def content_groups
    specialist_sectors[:options]
  end

  def specialist_sectors
    groupings[:facets][:specialist_sectors]
  end

  def groupings
    JSON.parse(content, symbolize_names: true)
  end
end
