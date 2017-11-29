class EditionTaxonsFetcher
  attr_accessor :content_id

  def initialize(content_id)
    @content_id = content_id
  end

  def fetch
    ExpandedLinks.new(
      Services.publishing_api.get_expanded_links(content_id)
    )
  rescue GdsApi::HTTPNotFound
    MissingExpandedLinks.new
  end

  # TODO: This is a workaround, because Publishing API
  # returns 404 when the document exists but there are no links
  # This can be removed when that changes.
  class MissingExpandedLinks
    def selected_taxon_paths
      []
    end
  end

  class ExpandedLinks
    def initialize(publishing_api_response)
      @response = publishing_api_response
    end

    def selected_taxon_paths
      visible_taxon_links.map { |taxon_hash| taxon_path(taxon_hash) }
    end

  private

    attr_reader :response

    def visible_taxon_links
      taxon_links.select do |taxon_link|
        published_taxon_content_ids.include?(taxon_link["content_id"]) ||
          visible_draft_taxon_content_ids.include?(taxon_link["content_id"])
      end
    end

    def taxon_links
      response["expanded_links"].fetch("taxons", [])
    end

    def published_taxon_content_ids
      govuk_taxonomy.matching_against_published_taxons(taxon_content_ids)
    end

    def visible_draft_taxon_content_ids
      govuk_taxonomy.matching_against_visible_draft_taxons(taxon_content_ids)
    end

    def taxon_content_ids
      taxon_links.map { |t| t["content_id"] }
    end

    def govuk_taxonomy
      Taxonomy::GovukTaxonomy.new
    end

    def taxon_path(taxon_hash)
      parents = [{ title: taxon_hash["title"] }]

      direct_parents = taxon_hash["links"]["parent_taxons"]
      while direct_parents
        # There should not be more than one parent for a taxon. If there is,
        # make an arbitrary choice.
        direct_parent = direct_parents.first

        parents << { title: direct_parent["title"] }

        direct_parents = direct_parent["links"]["parent_taxons"]
      end

      parents.reverse
    end
  end
end
