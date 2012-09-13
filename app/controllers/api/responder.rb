class Api::Responder < ActionController::Responder
  def to_json
    display resource.as_json.merge(response_info)
  end

  private

  def response_info
    status = @options[:status] || :ok
    code = Rack::Utils.status_code(status)
    text = Rack::Utils::HTTP_STATUS_CODES[code]
    {_response_info: {status: text.downcase}}
  end
end