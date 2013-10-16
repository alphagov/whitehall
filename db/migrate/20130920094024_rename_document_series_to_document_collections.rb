class Edition
  def can_index_in_search?
    false
  end
end

class DocumentCollection < Edition
  def create_default_group
  end
end

class RenameDocumentSeriesToDocumentCollections < ActiveRecord::Migration
  class DocumentSeriesGroupMembership < ActiveRecord::Base; end
  class DocumentSeriesGroup < ActiveRecord::Base; end
  class DocumentSeries < ActiveRecord::Base
    def public_timestamp
      @public_timestamp ||= DocumentSeriesGroup.where(document_series_id: self.id).map do |dsg|
        DocumentSeriesGroupMembership.where(document_series_group_id: dsg.id).map do |dsgm|
          Edition.where(document_id: dsgm.document_id)
            .where(state: "published")
            .select([:state, :public_timestamp])
            .order("public_timestamp desc")
            .limit(1)
            .map(&:public_timestamp)
        end
      end.flatten.max
      @public_timestamp ||= self.updated_at
    end
  end

  class DocumentCollectionGroupMembership < ActiveRecord::Base; end
  class DocumentCollectionGroup < ActiveRecord::Base
    has_many :document_collection_group_memberships
  end

  def up
    create_table "document_collection_group_memberships", force: true do |t|
      t.references  "document"
      t.references  "document_collection_group"
      t.integer  "ordering"
      t.timestamps
    end

    add_index "document_collection_group_memberships", ["document_id"]
    add_index "document_collection_group_memberships", ["document_collection_group_id", "ordering"], name: "index_dc_group_memberships_on_dc_group_id_and_ordering"

    create_table "document_collection_groups", force: true do |t|
      t.references  "document_collection"
      t.string   "heading"
      t.text     "body"
      t.integer  "ordering"
      t.timestamps
    end

    add_index "document_collection_groups", ["document_collection_id", "ordering"], name: "index_dc_groups_on_dc_id_and_ordering"

    migrate_all_document_series
  end

  def migrate_all_document_series
    total = DocumentSeries.where(state: "current").count
    puts "Migrating #{total} document series..."

    Edition::AuditTrail.whodunnit = creator
    start = Time.zone.now
    count = 0
    @failures = []
    DocumentSeries.where(state: "current").each do |ds|
      migrate_document_series(ds)
      count += 1
    end

    elapsed_time = time_since(start)
    puts "Migrated #{count-@failures.size}/#{total} DocumentSeries in #{elapsed_time}"
    if @failures.any?
      puts "#{@failures.size} error(s)"
      @failures.each do |document_series, failure|
        puts "DocumentSeries(#{document_series.id}): #{failure.record} - #{failure.record.errors.full_messages.to_sentence}"
      end
    else
      puts "No failures"
    end
  end

  def creator
    @creator ||= User.find_by_name!('GDS Inside Government Team')
  end

  def migrate_document_series(document_series)
    puts "Migrating #{document_series.id} #{document_series.slug} (#{document_series.public_timestamp})"

    dc = create_document_collection_for(document_series)
    create_document_collection_groups_for(document_series, dc)
    add_editorial_remark_to(dc)
  rescue ActiveRecord::RecordInvalid => e
    @failures << [document_series, e]
  end

  def create_document_collection_for(document_series)
    d = Document.create!(
      slug: document_series.slug,
      document_type: "DocumentCollection",
      created_at: document_series.public_timestamp,
      updated_at: document_series.public_timestamp
    )
    dc = DocumentCollection.create!(
      document_id: d.id,
      state: "published",
      major_change_published_at: document_series.public_timestamp,
      first_published_at: document_series.public_timestamp,
      public_timestamp: document_series.public_timestamp,
      published_major_version: 1,
      published_minor_version: 1,
      access_limited: false,
      lead_organisation_ids: [document_series.organisation_id],
      title: document_series.name,
      summary: document_series.summary,
      body: document_series.description.blank? ? '-' : document_series.description,
      creator: creator,
      created_at: document_series.created_at,
      updated_at: document_series.public_timestamp
    )
    puts "  doc #{d.id} ed #{dc.id}: #{document_series.name}"

    # Hack to fix timestamp of changenote
    dc.versions.last.update_column(:created_at, document_series.public_timestamp)

    dc
  end

  def create_document_collection_groups_for(document_series, dc)
    DocumentSeriesGroup.where(document_series_id: document_series.id).map do |group|
      dcg = DocumentCollectionGroup.create!(
        document_collection_id: dc.id,
        heading: group.heading,
        body: group.body,
        ordering: group.ordering,
        created_at: group.created_at,
        updated_at: group.updated_at
      )
      puts "    dc #{dcg.id}: #{group.heading}"

      DocumentSeriesGroupMembership.where(document_series_group_id: group.id).order(:ordering).map do |membership|
        dcgm = DocumentCollectionGroupMembership.create!(
          document_collection_group_id: dcg.id,
          document_id: membership.document_id,
          ordering: membership.ordering,
          created_at: membership.created_at,
          updated_at: membership.updated_at
        )
        puts "      #{membership.ordering}: dcgm #{dcgm.id}: (doc #{membership.document_id})"
      end
    end
  end

  def add_editorial_remark_to(collection)
    collection.editorial_remarks.create!(
      author: creator,
      body: "Automatically converted from a document series"
    )
  end

  def time_since(start)
    finish = Time.zone.now
    elapsed = finish - start
    minutes = elapsed / 60.0
    seconds = elapsed % 60
    "%dm %ds" % [minutes, seconds]
  end

  def down
    drop_table "document_collection_group_memberships"
    drop_table "document_collection_groups"
    execute "delete from editions where type='DocumentCollection'"
    execute "delete from documents where document_type='DocumentCollection'"
  end
end
