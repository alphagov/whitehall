# This enables us to redirect static pages published by PublishStaticPages
# to specified URLs.

class RedirectStaticPages
  def redirect
    pages.each do |page|
      PublishingApiRedirectWorker.new.perform(page[:content_id], page[:target_path], "en")
    rescue GdsApi::HTTPNotFound => e
      # we can't unpublish something that doesn't exist
      puts e
      nil
    end
  end

  def pages
    [
      {
        base_path: "/government/announcements",
        content_id: "88936763-df8a-441f-8b96-9ea0dc0758a1",
        target_path: "/redirect/announcements",
      },
    ]
  end
end
