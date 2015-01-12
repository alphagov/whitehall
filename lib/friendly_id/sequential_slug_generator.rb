module FriendlyId
  class SequentialSlugGenerator
    attr_accessor :scope, :slug, :slug_column, :sequence_separator

    def initialize(scope, slug, slug_column, sequence_separator)
      @scope = scope
      @slug = slug
      @slug_column = slug_column
      @sequence_separator = sequence_separator
    end

    def generate
      slug + sequence_separator + next_sequence_number.to_s
    end

  private

    def next_sequence_number
      if last_sequence_number == 0
        2
      else
        last_sequence_number + 1
      end
    end

    def last_sequence_number
      slug_conflicts.last.split("#{slug}#{sequence_separator}").last.to_i
    end

    def slug_conflicts
      scope.
        where(conflict_query, slug, sequential_slug_matcher).
        order(ordering_query).pluck(slug_column)
    end

    def conflict_query
      "#{slug_column} = ? OR #{slug_column} LIKE ?"
    end

    def sequential_slug_matcher
      # Underscores (matching a single character) and percent signs (matching
      # any number of characters) need to be escaped
      # (While this seems like an excessive number of backslashes, it is correct)
      "#{slug}#{sequence_separator}".gsub(/[_%]/, '\\\\\&') + '%'
    end

    # Return the unnumbered (shortest) slug first, followed by the numbered ones
    # in ascending order.
    def ordering_query
      "LENGTH(#{slug_column}) ASC, #{slug_column} ASC"
    end
  end
end
