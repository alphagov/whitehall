class AddProblemSummaryAndSuggestedFixToLinkChecker < ActiveRecord::Migration
  def change
    add_column :link_checker_api_report_links, :problem_summary, :text
    add_column :link_checker_api_report_links, :suggested_fix, :text
  end
end
