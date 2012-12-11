module FilterRoutesHelper
  def announcements_filter_path(*objects)
    announcements_path(path_arguments(objects))
  end

  def publications_filter_path(*objects)
    publications_path(path_arguments(objects))
  end

  def policies_filter_path(*objects)
    policies_path(path_arguments(objects))
  end

  private

  def path_arguments(objects)
    objects.inject({}) do |out, obj|
      if obj.is_a? Organisation
        out[:departments] = [obj.slug]
      elsif obj.is_a? Topic
        out[:topics] = [obj.slug]
      else
        out = out.merge(obj)
      end
      out
    end
  end
end
