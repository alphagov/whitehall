class ServicesAndInformationCollection
  attr_reader :document_count, :examples, :subsector_link, :title

  def initialize(params = {})
    @document_count = params.fetch(:document_count)
    @examples = params.fetch(:examples)
    @subsector_link = params.fetch(:subsector_link)
    @title = params.fetch(:title)
  end

  def self.build_collection_group_from(search_results)
    search_results.map do |content_group|
      self.new_collection_group_from(content_group)
    end
  end

  def self.new_collection_group_from(content_group)
    new(
      title: content_group[:title],
      examples: content_group[:examples],
      document_count: content_group[:document_count],
      subsector_link: content_group[:subsector_link],
    )
  end

  def title_for_example_at(index)
    examples[index][:title]
  end

  def link_for_example_at(index)
    examples[index][:link]
  end

  def more_documents?
    @document_count > @examples.count
  end
end
