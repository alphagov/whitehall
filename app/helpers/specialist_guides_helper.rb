module SpecialistGuidesHelper
  def results_count_for(results_count)
    if results_count > 0
      "#{pluralize(results_count, "results")} found for"
    else
      "We can't find any results for"
    end
  end
end

