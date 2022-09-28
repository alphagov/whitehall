class Document::PaginatedTimeline
  PER_PAGE = 30

  def initialize(document:, page:)
    @document = document
    @page = page.to_i
  end

  def entries
    paginated_query.rows.map do |row|
      model_name, id = row

      case model_name
      when "Version"
        version = versions.find(id)
        Document::PaginatedHistory::AuditTrailEntry.new(
          version,
          is_first_edition: false,
          previous_version: nil,
        )
      when "EditorialRemark"
        remarks.find(id)
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

  def versions
    @document.edition_versions
  end

  def remarks
    @document.editorial_remarks
  end

  def union_query
    common_fields = %i[id created_at]
    versions_query = versions.select("'#{versions.class_name}' AS model_name", *common_fields)
    remarks_query = remarks.select("'#{remarks.class_name}' AS model_name", *common_fields)

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
end
