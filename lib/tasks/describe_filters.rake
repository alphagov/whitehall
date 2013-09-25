
desc "Takes a file containing a list of filter page urls and outputs the descriptions of the filter options"
task :describe_filters, [:topic_list_csv] => :environment do |t, args|
  require 'uri'
  require 'rack'
  require 'json'

  class FilterHelper < Struct.new(:params)
    include DocumentFilterHelper
    include Rails.application.routes.url_helpers
    Rails.application.routes.default_url_options[:host] = "www.gov.uk"
    Rails.application.routes.default_url_options[:protocol] = "https"
  end

  def parse_params(line)
    uri = URI.parse(line.gsub(';', "%#{';'.ord.to_s(16).upcase}"))

    params = HashWithIndifferentAccess.new(Rack::Utils.parse_nested_query(uri.query))
    params['topics'] = params['topics'].map {|t| t.split(";")}.flatten
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
    h = FilterHelper.new(params)

    {
      type: params[:controller],
      departments: h.filter_results_selections(filter.selected_organisations, 'departments').map {|h| h[:name]},
      topics: h.filter_results_selections(filter.selected_topics, 'topics').map {|h| h[:name]},
      world_locations: h.filter_results_selections(filter.selected_locations, 'world_locations').map {|h| h[:name]},
      keywords: h.filter_results_keywords(filter.keywords),
      relevant_to_local_government: filter.relevant_to_local_government ? "relevant to local government" : "",
      include_world_location_news: filter.include_world_location_news ? "including location-specific news" : ""
    }
  end

  File.open(args[:topic_list_csv]).each_line.with_index do |line, i|
    next unless line =~ /^http/
    params = parse_params(line)
    puts describe(params).reverse_merge(url: line.strip).to_json
  end

end