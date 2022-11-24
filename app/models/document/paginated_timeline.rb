class Document::PaginatedTimeline
  PER_PAGE = 30

  def initialize(document:, page:)
    @document = document
    @page = page.to_i
  end

  def entries
    @entries ||= begin
      raw_entries = paginated_query.rows.map { |r| RawEntry.new(r) }

      remarks = get_remarks_hash raw_entries.select { |r| r.model == "EditorialRemark" }.map(&:id)
      versions = get_versions_hash raw_entries.select { |r| r.model == "Version" }.map(&:id)

      raw_entries.map do |entry|
        case entry.model
        when "Version"
          versions.fetch(entry.id)
        when "EditorialRemark"
          remarks.fetch(entry.id)
        end
      end
    end
  end

  def entries_on_newer_editions(edition)
    @entries_on_newer_editions ||= entries.select do |entry|
      if entry.is_a?(EditorialRemark)
        entry.edition_id > edition.id
      else
        entry.version.item_id > edition.id
      end
    end
  end

  def entries_on_current_edition(edition)
    @entries_on_current_edition ||= entries.select do |entry|
      if entry.is_a?(EditorialRemark)
        entry.edition_id == edition.id
      else
        entry.version.item_id == edition.id
      end
    end
  end

  def entries_on_previous_editions(edition)
    @entries_on_previous_editions ||= entries.select do |entry|
      if entry.is_a?(EditorialRemark)
        entry.edition_id < edition.id
      else
        entry.version.item_id < edition.id
      end
    end
  end

  def total_count
    @total_count ||= begin
      sql = "SELECT COUNT(*) FROM (#{union_query}) x"
      ApplicationRecord.connection.exec_query(sql).rows[0][0]
    end
  end

  def total_pages
    (total_count / PER_PAGE.to_f).ceil
  end

  def current_page
    @page
  end

  def limit_value
    PER_PAGE
  end

  def next_page
    if current_page < total_pages
      current_page + 1
    else
      false
    end
  end

  def prev_page
    if current_page > 1
      current_page - 1
    else
      false
    end
  end

private

  class RawEntry
    attr_reader :model, :id

    def initialize(row)
      @model = row[0]
      @id = row[1]
    end
  end
  private_constant :RawEntry

  def document_versions
    @document.edition_versions
  end

  def document_remarks
    @document.editorial_remarks
  end

  def first_edition_id
    @first_edition_id ||= @document.editions.pick(:id)
  end

  def union_query
    common_fields = %i[id created_at]
    versions_query = document_versions.select("'#{document_versions.class_name}' AS model_name", *common_fields)
    remarks_query = document_remarks.select("'#{document_remarks.class_name}' AS model_name", *common_fields)

    "(#{versions_query.to_sql}) UNION (#{remarks_query.to_sql})"
  end

  def paginated_query
    sql = <<~SQL
      #{union_query}
      ORDER BY created_at DESC
      LIMIT ? OFFSET ?
    SQL

    limit = PER_PAGE
    offset = (@page - 1) * PER_PAGE

    bind_params = [
      ActiveRecord::Relation::QueryAttribute.new("", limit, ActiveRecord::Type::Integer.new),
      ActiveRecord::Relation::QueryAttribute.new("", offset, ActiveRecord::Type::Integer.new),
    ]

    ApplicationRecord.connection.exec_query(sql, "SQL", bind_params)
  end

  def get_versions_hash(ids)
    versions = document_versions.where(id: ids)
    versions.map.with_index { |version, index|
      presenter = Document::PaginatedHistory::AuditTrailEntry.new(
        version,
        is_first_edition: version.item_id == first_edition_id,
        previous_version: versions[index - 1],
      )
      [version.id, presenter]
    }.to_h
  end

  def get_remarks_hash(ids)
    document_remarks.where(id: ids).index_by(&:id)
  end
end
