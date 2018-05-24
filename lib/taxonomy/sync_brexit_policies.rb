module Taxonomy
  class SyncBrexitPolicies
    attr_reader :log

    BREXIT_POLICY_ID = '2dcb5926-db6e-4347-b6d8-64fa9d5779a5'.freeze
    BREXIT_TAXON_ID = 'd6c2de5d-ef90-45d1-82d4-5f2438369eea'.freeze

    def initialize
      @log = []
    end

    def call
      patch_editions
    end

  private

    def brexit_policy_editions_query
      Document.joins(:editions)
        .joins('INNER JOIN edition_policies on editions.id = edition_policies.edition_id')
        .where(editions: { state: 'published' }, edition_policies: { policy_content_id: BREXIT_POLICY_ID })
        .pluck(:content_id)
    end

    def links_for_brexit_policy_editions
      Services.publishing_api.get_links_for_content_ids(brexit_policy_editions_query)
    end

    def patch_editions
      links_for_brexit_policy_editions.each do |content_id, edition_links|
        edition_taxons = edition_links.dig("links", "taxons") || []

        unless edition_taxons.include?(BREXIT_TAXON_ID)
          Services.publishing_api.patch_links(
            content_id,
            links: {
              taxons: edition_taxons << BREXIT_TAXON_ID
            },
            previous_version: edition_links.dig("version")
          )
        end
      end
    rescue GdsApi::HTTPConflict, GdsApi::HTTPGatewayTimeout, GdsApi::TimedOutException => ex
      log << "ERROR: #{ex.message}"
      retries ||= 0
      retry if (retries += 1) < 3
      puts log
      raise
    end
  end
end
