class EditionTaxonsFetcher
  attr_accessor :content_id

  def initialize(content_id)
    @content_id = content_id
  end

  def fetch
    response =  Services.publishing_api.get_expanded_links(content_id)
    ExpandedLinks.new(response).visible_taxons
  rescue GdsApi::HTTPNotFound
    []
  end

  class ExpandedLinks
    def initialize(publishing_api_response)
      @response = publishing_api_response
    end

    def visible_taxons
      taxons.select do |taxon|
        published_taxon_content_ids.include?(taxon.content_id) ||
          visible_draft_taxon_content_ids.include?(taxon.content_id)
      end
    end

  private

    attr_reader :response

    def taxons
      @_taxons ||= taxon_links.map { |taxon_link| build_taxon(taxon_link) }
    end

    def build_taxon(taxon_link)
      taxon = Taxonomy::Taxon.new(taxon_link.symbolize_keys.slice(:title, :base_path, :content_id))

      parent_taxons = taxon_link.fetch("links", {}).fetch("parent_taxons", [])
      if parent_taxons.present?
        # There should not be more than one parent for a taxon. If there is,
        # pick the first one.
        taxon.parent_node = build_taxon(parent_taxons.first)
      end

      taxon
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
  end
end
