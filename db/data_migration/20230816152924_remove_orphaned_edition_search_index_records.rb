class RemoveOrphanedEditionSearchIndexRecords < ActiveRecord::Migration[7.0]
  def change
    # We want to find all editions which are publicly visible and therefore might once have been indexed, but are currently not searchable
    # We then ask Search API to remove the record for these editions if a corresponding record is present
    # Note that this doesn't seem to capture all foreign language content in the search index, but it has removed at least some
    editions_with_possible_orphaned_search_index_records = Edition.publicly_visible.where.not(id: Edition.search_only.select(:id))
    editions_with_possible_orphaned_search_index_records.each { |e| ServiceListeners::SearchIndexer.new(e).remove! }
  end
end
