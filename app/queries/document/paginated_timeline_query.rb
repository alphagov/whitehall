class Document
  class PaginatedTimelineQuery
    PER_PAGE = 10

    Result = Data.define(:model, :id, :created_at)

    def initialize(document:, page:, only: nil)
      @document = document
      @page = page
      @only = only
    end

    def raw_entries
      @raw_entries ||= paginated_query.rows.map { |r| Result.new(model: r[0], id: r[1], created_at: r[2]) }
    end

    def total_count
      @total_count ||= begin
        sql = "SELECT COUNT(*) FROM (#{timeline_sql}) x"
        ApplicationRecord.connection.exec_query(sql).rows[0][0]
      end
    end

    def remark_ids
      raw_entries.select { |r| r.model == "EditorialRemark" }.map(&:id)
    end

    def version_ids
      raw_entries.select { |r| r.model == "Version" }.map(&:id)
    end

  private

    attr_reader :document, :page, :only

    def paginated_query
      sql = <<~SQL
        #{timeline_sql}
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

    def timeline_sql
      case only
      when "history"
        "(#{versions_query})"
      when "internal_notes"
        "(#{remarks_query})"
      else
        "(#{versions_query}) UNION (#{remarks_query})"
      end
    end

    def versions_query
      document.active_edition_versions.select(
        "'#{Version}' AS model_name",
        *common_fields,
      ).to_sql
    end

    def remarks_query
      document.editorial_remarks.select(
        "'#{EditorialRemark}' AS model_name",
        *common_fields,
      ).to_sql
    end

    def common_fields
      %i[id created_at]
    end
  end
end
