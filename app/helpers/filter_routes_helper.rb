module FilterRoutesHelper
  def announcements_filter_path(obj)
    if obj.is_a? Organisation
      announcements_path(departments: [obj.slug])
    end
  end

  def publications_filter_path(obj)
    if obj.is_a? Organisation
      publications_path(departments: [obj.slug])
    end
  end

  def policies_filter_path(obj)
    if obj.is_a? Organisation
      policies_path(departments: [obj.slug])
    end
  end

  def specialist_guides_filter_path(obj)
    if obj.is_a? Organisation
      specialist_guides_path(departments: [obj.slug])
    elsif obj.is_a? Topic
      specialist_guides_path(topics: [obj.slug])
    end
  end
end
