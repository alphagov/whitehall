module FilterRoutesHelper
  def publications_filter_path(*objects)
    query_string = path_arguments(objects).to_query
    "/search/all?#{query_string}"
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
