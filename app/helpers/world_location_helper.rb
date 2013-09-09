module WorldLocationHelper

  def group_and_sort(locations)
    locations.sort_by(&:name_without_prefix).group_by {|location| location.name_without_prefix.first.upcase }.sort
  end

end
