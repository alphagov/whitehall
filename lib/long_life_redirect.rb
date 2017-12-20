require 'action_dispatch/http/request'

# NOTE: the call method here is very similar to redirection_proc in
# ActionDispatch::Routing::Redirection.  Just because we want to set
# the expires header as well as do a redirect, so we can't use the simple
# redirect() route helper :(
class LongLifeRedirect
  def initialize(root_path, age = 1.year)
    @root_path = root_path
    @root_path << '/' unless @root_path.ends_with?('/')
    @age = age
  end

  def call(env)
    req = ActionDispatch::Request.new(env)

    params = req.path_parameters
    path_and_filename = [params[:path], params[:format]].join(".")

    uri = Addressable::URI.parse(@root_path + path_and_filename)
    uri.scheme ||= req.scheme
    uri.host   ||= req.host
    uri.port   ||= req.port unless req.standard_port?

    body = %(<html><body>You are being <a href="#{ERB::Util.h(uri.to_s)}">redirected</a>.</body></html>)

    headers = {
      'Location' => uri.to_s,
      'Content-Type' => 'text/html',
      'Content-Length' => body.length.to_s,
      'Expires' => @age.from_now.httpdate,
      'Cache-control' => 'public'
    }

    [301, headers, [body]]
  end
end
