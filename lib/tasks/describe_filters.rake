desc "Takes a file containing a list of filter page urls and outputs the descriptions of the filter options"
task :describe_filters, [:topic_list_csv] => :environment do |_t, args|
  require 'rack'
  require 'json'

  FilterHelper = Struct.new(:params) do
    include DocumentFilterHelper
    include Rails.application.routes.url_helpers
    Rails.application.routes.default_url_options[:host] = "www.gov.uk"
    Rails.application.routes.default_url_options[:protocol] = "https"
  end

  def parse_params(line)
    uri = Addressable::URI.parse(line.gsub(';', "%#{';'.ord.to_s(16).upcase}"))

    params = ActiveSupport::HashWithIndifferentAccess.new(Rack::Utils.parse_nested_query(uri.query))
    params['topics'] = params['topics'].map { |t| t.split(";") }.flatten
    params[:action] = "index"
    params[:controller] = case uri.path
                          when "/government/publications.atom"
                            "publications"
                          when "/government/announcements.atom"
                            "announcements"
                          else
                            raise "Unexpected uri: #{uri}"
                          end

    params
  end

  def describe(params)
    filter = Whitehall::DocumentFilter::Filterer.new(params)
    filter_helper = FilterHelper.new(params)

    departments = filter_helper
                    .filter_results_selections(filter.selected_organisations, 'departments')
                    .map { |h| h[:name] }

    topics = filter_helper
               .filter_results_selections(filter.selected_topics, 'topics')
               .map { |h| h[:name] }

    world_locations = filter_helper
                        .filter_results_selections(filter.selected_locations, 'world_locations')
                        .map { |h| h[:name] }

    keywords = filter_helper
                 .filter_results_keywords(filter.keywords)

    include_world_location_news = if filter.include_world_location_news
                                    "including location-specific news"
                                  else
                                    ""
                                  end

    {
      type: params[:controller],
      departments: departments,
      topics: topics,
      world_locations: world_locations,
      keywords: keywords,
      include_world_location_news: include_world_location_news,
    }
  end

  File.open(args[:topic_list_csv]).each_line.with_index do |line, _i|
    next unless line =~ /^http/
    params = parse_params(line)
    puts describe(params).reverse_merge(url: line.strip).to_json
  end
end
