class AddEditionIdToLinkCheckerApiReports < ActiveRecord::Migration[8.0]
  def up
    unless column_exists?(:link_checker_api_reports, :edition_id)
      add_reference :link_checker_api_reports, :edition, type: :integer, index: true, foreign_key: true
    end
  end

  def down
    remove_reference :link_checker_api_reports, :edition, foreign_key: true
  end
end
