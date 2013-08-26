class CreateDocumentSeriesGroups < ActiveRecord::Migration
  class DocumentSeries < ActiveRecord::Base
    has_many :document_series_memberships
    has_many :groups, class_name: 'DocumentSeriesGroup'
  end

  class DocumentSeriesMembership < ActiveRecord::Base
    belongs_to :document_series
    belongs_to :document
  end

  class DocumentSeriesGroup < ActiveRecord::Base
    belongs_to :document_series
    has_many :memberships, class_name: 'DocumentSeriesGroupMembership'
    has_many :documents, through: :memberships
  end

  def change
    create_table :document_series_groups do |t|
      t.integer :document_series_id
      t.string :heading
      t.text :body
      t.integer :ordering

      t.timestamps
    end

    create_table :document_series_group_memberships do |t|
      t.integer :document_id
      t.integer :document_series_group_id
      t.integer :ordering

      t.timestamps
    end

    DocumentSeries.includes(:document_series_memberships).find_each do |series|
      series.document_series_memberships.each do |membership|
        group = series.groups.first_or_create!(DocumentSeriesGroup.default_attributes)
        group.documents << membership.document
      end
    end

    add_index :document_series_groups, [:document_series_id, :ordering]

    add_index :document_series_group_memberships, :document_id
    add_index :document_series_group_memberships,
              [:document_series_group_id, :ordering],
              name: 'index_document_series_memberships_on_group_id_and_ordering'
  end
end
