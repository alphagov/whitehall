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
        subsector_link: group[:value][:link],
      }
    end
  end

  def content_groups
    content.facets.specialist_sectors.options
  end
end
