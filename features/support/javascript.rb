require 'capybara/poltergeist'
# static.preview SSL certificate is causing errors in Cucumber tests, # so we're ignoring SSL errors for now.
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, { phantomjs_options: ['--ignore-ssl-errors=yes']})
end
Capybara.javascript_driver = :poltergeist

require "slimmer/test"

Before('@javascript') do
  ENV["USE_SLIMMER"] = "true"
end

After('@javascript') do
  ENV.delete("USE_SLIMMER")
end

# Capybara 2 is a lot stricter with the elements that it finds. Not only does it complain if your
# selector matches more than one element, but it also doesn't like interacting with invisible elements.
# And because we use the chosen jQuery extension to enhance admin form select fields, we need some
# jiggery pokery to make sure we can select stuff in our javascript-enabled tests.
module Capybara::DSL
  def select(value, options={})
    if options.has_key?(:from)
      element = find(:select, options[:from], visible: :all).find(:option, value, visible: :all)
      if element.visible?
        from = options.delete(:from)
        find(:select, from, options).find(:option, value, options).select_option
      else
        select_from_chosen(value, options)
      end
    else
      find(:option, value, options).select_option
    end
  end

  def select_from_chosen(value, options={})
    field = find_field(options[:from], visible: false, match: :first)
    option_value = page.evaluate_script("$(\"##{field[:id]} option:contains('#{value}')\").val()")

    if field[:multiple]
      page.execute_script("value = ['#{option_value}']\; if ($('##{field[:id]}').val()) {$.merge(value, $('##{field[:id]}').val())}")
      option_value = page.evaluate_script("value")
    end

    page.execute_script("$('##{field[:id]}').val(#{option_value.to_json})")
    page.execute_script("$('##{field[:id]}').trigger('liszt:updated').trigger('change')")
  end
end

# This monkey catches Capybara::Poltergeist::TimeoutErrors and logs out network traffic before re-raising.
class Capybara::Poltergeist::WebSocketServer
  alias_method :_send, :send

  def send(message)
    _send(message)
  rescue Capybara::Poltergeist::TimeoutError => e
    log_network_traffic
    raise e
  end

private

  def log_network_traffic(opts = {})
    traffic = Capybara.page.driver.network_traffic
    traffic = traffic.select { |request| request.response_parts.empty? } if opts[:hide_completed]

    traffic.each do |request|
      puts render_network_traffic_request(request)
    end
  end

  def render_network_traffic_request(request)
    request_complete = request.response_parts.any?
    %{
      #{request.method}: #{request.url}
      Complete: #{request_complete}
      Duration: #{request_complete ?(request.response_parts.last.time - request.time) : (Time.zone.now.localtime - request.time)}
    }
  end
end
