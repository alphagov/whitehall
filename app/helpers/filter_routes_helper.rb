module FilterRoutesHelper
  def announcements_filter_path(*objects)
    announcements_path(path_arguments(objects))
  end

  def publications_filter_path(*objects)
    publications_path(path_arguments(objects))
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
        out[:departments] = [obj.slug]
      when TopicalEvent
        out[:topical_events] = [obj.slug]
      when WorldLocation
        out[:world_locations] = [obj.slug]
      else
        out = out.merge(obj)
      end
      out
    end
  end
end
