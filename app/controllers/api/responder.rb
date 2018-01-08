class Api::Responder < ActionController::Responder
  def to_json
    display resource.as_json.merge(response_info)
  end

  def display(*args)
    set_links_header
    super
  end

private

  def response_info
    response_info = { status: status_for_response_info }
    response_info[:links] = links_for_response_info if link_header.links.any?

    { _response_info: response_info }
  end

  def status_for_response_info
    status = @options[:status] || :ok
    code = Rack::Utils.status_code(status)
    text = Rack::Utils::HTTP_STATUS_CODES[code]
    text.downcase
  end

  def link_header
    @link_hedaer ||= extract_link_header_from_options_and_resource
  end

  def extract_link_header_from_options_and_resource
    links = resource.links if resource.respond_to?(:links)
    links ||= []
    links |= (@options[:links] || [])
    links_for_link_header = links.map {|(url, attrs)| [url, attrs.to_a]}
    LinkHeader.new(links_for_link_header)
  end

  def set_links_header
    controller.headers["Link"] = link_header.to_s if link_header.links.any?
  end

  def links_for_response_info
    link_header.links.map do |link|
      { href: link.href }.merge(link.attrs.symbolize_keys)
    end
  end
end
