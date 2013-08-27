module Admin::DocumentSeriesGroupsHelper
  def other_groups(group)
    @groups.reject { |candidate| candidate == group }
  end
end
