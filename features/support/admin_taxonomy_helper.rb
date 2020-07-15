require_relative "../../test/support/taxonomy_helper"
module AdminTaxonomyHelper
  include TaxonomyHelper

  def select_taxon(label)
    check label
  end

  def select_taxon_and_save(label)
    select_taxon(label)
    click_button "Save topic changes"
  end

  def stub_taxonomy_data
    redis_cache_has_taxons [root_taxon, draft_taxon1, draft_taxon2]
  end

  def stub_patch_links
    Services.publishing_api.stubs(patch_links: { status: 200 })
  end

  def check_links_patched_in_publishing_api
    assert_respond_to(Services.publishing_api, :patch_links)
  end
end
World(AdminTaxonomyHelper)
