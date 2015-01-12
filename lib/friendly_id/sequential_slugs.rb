module FriendlyId
  # Module that patches friendly_id to produce sequentially numbered slugs.
  # This replicates the behaviour of v4 instead of the new default behaviour in
  # v5, which is to append a GUID to a conflicted slug.
  module SequentialSlugs
    # This uses babosa gem's `noramlize` method for better string parameterisation
    def normalize_friendly_id(input)
      super input.to_s.to_slug.truncate(150).normalize.to_s
    end

    def resolve_friendly_id_conflict(candidate_slugs)
      SequentialSlugGenerator.new(scope_for_slug_generator,
                                 candidate_slugs.first,
                                 friendly_id_config.slug_column,
                                 friendly_id_config.sequence_separator).generate
    end
  end
end
