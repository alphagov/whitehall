require_relative "../../test/support/taxonomy_helper"
module AdminTaxonomyHelper
  include TaxonomyHelper

  def select_taxon(label)
    check label
  end

  def select_taxon_and_save(label, save_btn_label)
    select_taxon(label)
    click_button save_btn_label
  end

  def stub_taxonomy_data
    redis_cache_has_taxons [root_taxon, draft_taxon1, draft_taxon2]
  end

  def stub_patch_links
    Services.publishing_api.stubs(patch_links: { status: 200 })
  end

  def check_links_patched_in_publishing_api
    expect(Services.publishing_api).to respond_to(:patch_links)
  end
end
World(AdminTaxonomyHelper)

Around do |_, block|
  redis = Redis.new
  Redis.new = nil
  block.call
ensure
  Redis.new = redis
end
