# Creates a payload for the topic (formerly specialist sector) select box.
class LinkableTopics
  CACHE_OPTIONS = { expires_in: 15.minutes, race_condition_ttl: 30.seconds }.freeze

  def topics
    items = raw_topics
    items = group_for_grouped_select(items)
    alphabetize_by_parent(items)
  end

  def raw_topics
    items = fetch_linkables_from_publishing_api(document_type: "topic")
    items = change_separator(items)
    items = select_only_subtopics(items)
    items = filter_browse_topics(items)
    format_for_select_input(items)
  end

  def taxons
    items = fetch_linkables_from_publishing_api(document_type: "taxon")
    items = items.sort_by { |item| item["internal_name"] }
    format_for_select_input(items)
  end

private

  def fetch_linkables_from_publishing_api(document_type:)
    Services.publishing_api.get_linkables(document_type: document_type)
  end

  # collections-publisher uses a slash to separate the top-level topic name from
  # the second-level topic (or "subtopic"). Whitehall has historically used a colon,
  # so we'll change that here.
  def change_separator(items)
    items.map do |item|
      item["internal_name"] = item.fetch("internal_name").gsub(" / ", ": ")
      item
    end
  end

  # Documents can only be tagged to subtopics, eg. /topic/business-tax/capital-allowances,
  # but not https://www.gov.uk/topic/business-tax
  def select_only_subtopics(all_topics)
    all_topics.select { |item| item.fetch("internal_name").include?(": ") }
  end

  # While we're migrating the Browse pages to topics we will briefly have a combination of the
  # two in our model. We need to filter out the pages we brought across from the results.
  def filter_browse_topics(all_topics)
    return all_topics if all_topics.empty? || all_topics.first.fetch("base_path").exclude?("/topic/")

    # Get topics that are not mainstream browse copies
    valid_topics ||= Rails.cache.fetch("valid_topics", CACHE_OPTIONS) do
      Services.publishing_api.get_content_items(document_type: "topic", per_page: 10_000, fields: %w[content_id details])["results"].select do |item|
        item.dig("details", "mainstream_browse_origin").nil?
      end
    end

    # Filter the invalid topics out of the items collection
    all_topics.select { |item| valid_topics.any? { |topic| topic.fetch("content_id") == item.fetch("content_id") } }
  end

  def format_for_select_input(items)
    items.map do |item|
      title = item.fetch("internal_name")
      title = "#{title} (draft)" if item.fetch("publication_state") == "draft"

      select_value = item.fetch("content_id")

      [title, select_value]
    end
  end

  # Grouping in a nested array will make Rails show the options in a grouped select
  def group_for_grouped_select(items)
    items.group_by { |entry| entry.first.split(": ").first }
  end

  def alphabetize_by_parent(items)
    items.sort_by(&:first)
  end
end
