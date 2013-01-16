class RemoveDocumentSeriesIdFromEdition < ActiveRecord::Migration
  def up
    say "Moving document_series_id to EditionDocumentSeries"
    editions = Edition.where(Edition.arel_table[:document_series_id].not_eq(nil))
    total_count = editions.count
    changed_count = 0
    editions.find_each do |e|
      if e.document_series_id
        EditionDocumentSeries.create({
            edition_id: e.id,
            document_series_id: e.document_series_id
          })
        changed_count += 1
      end
    end

    say "Editions with a document_series_id: #{total_count}"
    say "EditionDocumentSeries num created : #{changed_count}"

    remove_column :editions, :document_series_id
  end

  def down
    add_column :editions, :document_series_id, :integer
  end
end
