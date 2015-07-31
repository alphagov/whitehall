require 'plek'
require 'gds_api/router'

class GdsApi::UrlArbiter < GdsApi::Base
  def publishing_app_for_path(path)
    response = get_json("#{endpoint}/paths#{path}")
    response["publishing_app"] if response
  end

  def set_publishing_app_for_path(path, app)
    put_json!("#{endpoint}/paths#{path}", "publishing_app" => app)
  end
end


router_api = GdsApi::Router.new(Plek.find('router-api'))
url_arbiter = GdsApi::UrlArbiter.new(Plek.find('url-arbiter'))

scope = Document.distinct.
  joins(:editions).
  where(document_type: "DetailedGuide",
    editions: {state: Edition::POST_PUBLICATION_STATES})

count = scope.count

scope.each_with_index do |guide, i|
  if guide.ever_published_editions.any?
    slug = guide.slug.sub(%r{^deleted-}, '')
    publishing_app = url_arbiter.publishing_app_for_path("/#{slug}")
    if publishing_app && publishing_app != "whitehall"
      puts "WARNING: Couldn't add route for /#{slug}, owned by #{publishing_app}"
      next
    elsif publishing_app.nil?
      url_arbiter.set_publishing_app_for_path("/#{slug}", "whitehall")
    end
    puts "Adding route #{i+1}/#{count} for /#{slug}"
    router_api.add_route("/#{slug}", "exact", "whitehall-frontend")
  end
end

router_api.commit_routes
