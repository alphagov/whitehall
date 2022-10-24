module FilterRoutesHelper
  def announcements_filter_path(*objects)
    query_string = path_arguments(objects).to_query
    "/search/news-and-communications?#{query_string}"
  end

  def publications_filter_path(*objects)
    query_string = path_arguments(objects).to_query
    "/search/all?#{query_string}"
  end

  def filter_atom_feed_url
    Whitehall::FeedUrlBuilder.new(
      params.to_unsafe_hash.merge(document_type: params[:controller].to_s).symbolize_keys,
    ).url
  end

  def filter_json_url(args = {})
    url_for(params.except(:utf8, :_).merge(format: "json").merge(args))
  end

protected

  def path_arguments(objects)
    objects.reduce({}) do |out, obj|
      case obj
      when Organisation
        out[:organisation] = obj.slug
      when TopicalEvent
        out[:topical_events] = [obj.slug]
      when WorldLocation
        out[:world_locations] = [obj.slug]
      else
        out = out.merge(obj)
      end
      out["order"] = "updated-newest"
      out
    end
  end
end
