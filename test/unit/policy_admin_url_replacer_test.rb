require 'test_helper'
require 'policy_admin_url_replacer'

class PolicyAdminURLReplacerTest < ActiveSupport::TestCase
  def setup
    old_policies = [create(:published_policy), create(:published_policy), create(:published_policy)]
    old_policies[0..1].each {|p| p.unpublish; p.delete! }

    old_sps = [create(:published_supporting_page), create(:published_supporting_page), create(:published_supporting_page)]
    old_sps[0..1].each {|sp| sp.unpublish; sp.delete! }

    @policy = create(:published_policy, title: "Test policy")
    @supporting_page = create(:published_supporting_page, title: "Test supporting page", related_policies: [@policy])
  end

  test "replaces policies and supporting pages by ID and slug" do
    edition = create(:publication, body: %{
      # Generic "editions" links
      [policy link](/government/admin/editions/#{@policy.id})
      [policy link](/government/admin/editions/#{@policy.slug})
      [sp link](/government/admin/editions/#{@supporting_page.id})
      [sp link](/government/admin/editions/#{@supporting_page.slug})

      # Explicit links to subclassed resources
      [policy link](/government/admin/policies/#{@policy.id})
      [policy link](/government/admin/policies/#{@policy.slug})
      [sp link](/government/admin/supporting-pages/#{@supporting_page.id})
      [sp link](/government/admin/supporting-pages/#{@supporting_page.slug})

      # Generic "editions" full URLs
      [policy link](https://www.gov.uk/government/admin/editions/#{@policy.id})
      [policy link](https://whitehall-admin.production.alphagov.co.uk/government/admin/editions/#{@policy.id})

      # Supporting page sub-links
      [sp link](/government/admin/policies/#{@policy.id}/supporting-pages/#{@supporting_page.id})
      [sp link](/government/admin/policies/#{@policy.id}/supporting-pages/#{@supporting_page.slug})
      [sp link](/government/admin/editions/#{@policy.id}/supporting-pages/#{@supporting_page.id})
    })

    PolicyAdminURLReplacer.replace_in!(Edition.all)

    assert_all_admin_links_replaced(edition)
    assert_correct_replacement_url(edition)
  end

  test "replaces links when policies have been deleted" do
    edition = create(:publication, body: %{
      [policy link](/government/admin/editions/#{@policy.id})
      [sp link](/government/admin/editions/#{@policy.id}/supporting-pages/#{@supporting_page.id})
    })

    @policy.unpublish
    @policy.delete!

    PolicyAdminURLReplacer.replace_in!(Edition.all)

    assert_all_admin_links_replaced(edition)
    assert_correct_replacement_url(edition)
  end

  test "replaces links when supporting pages have been deleted" do
    edition = create(:publication, body: %{
      [sp link](/government/admin/editions/#{@policy.id}/supporting-pages/#{@supporting_page.id})
    })

    @supporting_page.unpublish
    @supporting_page.delete!

    PolicyAdminURLReplacer.replace_in!(Edition.all)

    assert_all_admin_links_replaced(edition)
    assert_correct_replacement_url(edition)
  end

  test "replaces links when supporting pages have been superseded" do
    edition = create(:publication, body: %{
      [sp link](/government/admin/editions/#{@policy.id}/supporting-pages/#{@supporting_page.id})
      [sp link](/government/admin/supporting-pages/#{@supporting_page.id})
    })

    @supporting_page.supersede!

    PolicyAdminURLReplacer.replace_in!(Edition.all)

    assert_all_admin_links_replaced(edition)
    assert_correct_replacement_url(edition)
  end

  test "retains title text" do
    edition = create(:publication, body: %{
      [policy link](/government/admin/policies/#{@policy.id} "Policy title text")
      [sp link](/government/admin/policies/#{@policy.id}/supporting-pages/#{@supporting_page.id} "Supporting page title text")
    })

    PolicyAdminURLReplacer.replace_in!(Edition.all)

    assert_all_admin_links_replaced(edition)
    assert edition.body.include?(%{ "Policy title text"})
    assert edition.body.include?(%{ "Supporting page title text"})
  end

  test "deals with the policy having been hard-deleted" do
    edition = create(:publication, body: %{
      [policy link](/government/admin/editions/#{@policy.id})
      [sp link](/government/admin/editions/#{@policy.id}/supporting-pages/#{@supporting_page.id})
    })

    Policy.connection.delete("DELETE FROM editions WHERE id = #{@policy.id}")

    PolicyAdminURLReplacer.replace_in!(Edition.all)

    assert_all_admin_links_erased(edition)
  end

  test "deals with long form direct admin links outside of markdown wrappers" do
    edition = create(:publication, body: %{
      Pre-Work Programme schemes [give Jobcentre Plus choice over what support to offer to claimants](https://www.gov.uk/government/policies/helping-people-to-find-and-stay-in-work/supporting-pages/introducing-measures-to-give-jobcentre-plus-flexibility-in-helping-people-back-to-work) in their area based on claimant and local labour market characteristics.
      Some of these schemes are mandatory.
      <a class="some-class" href="https://whitehall-admin.production.alphagov.co.uk/government/admin/editions/#{@policy.id}/supporting-pages/#{@supporting_page.id}">Work Programme</a>
      On 27 June 2013
      we published [Work Programme – Programme costs to 31 March 2013 – Financial information on Work Programme costs](/government/admin/publications/209240) to provide additional context for the official statistics.
    })

    PolicyAdminURLReplacer.replace_in!(Edition.all)

    edition.reload

    assert edition.body.include?("Some of these schemes are mandatory.")
    assert_correct_replacement_url(edition)
  end

  test "deals with short form direct admin links outside of markdown wrappers" do
    edition = create(:publication, body: %{
      Pre-Work Programme schemes [give Jobcentre Plus choice over what support to offer to claimants](https://www.gov.uk/government/policies/helping-people-to-find-and-stay-in-work/supporting-pages/introducing-measures-to-give-jobcentre-plus-flexibility-in-helping-people-back-to-work) in their area based on claimant and local labour market characteristics.
      Some of these schemes are mandatory.
      <a class="some-class" href="https://whitehall-admin.production.alphagov.co.uk/government/admin/editions/#{@policy.id}">Work Programme</a>
      <a href="https://whitehall-admin.production.alphagov.co.uk/government/admin/supporting-pages/#{@supporting_page.id}" id="some-id">Work Programme</a>
      On 27 June 2013
      we published [Work Programme – Programme costs to 31 March 2013 – Financial information on Work Programme costs](/government/admin/publications/209240) to provide additional context for the official statistics.
    })

    PolicyAdminURLReplacer.replace_in!(Edition.all)

    edition.reload

    assert edition.body.include?("Some of these schemes are mandatory.")
    assert edition.body.include?("policies/#{@policy.slug}\">")
    assert edition.body.include?("policies/#{@policy.slug}/supporting-pages/#{@supporting_page.slug}")
  end

  def assert_all_admin_links_replaced(edition)
    remaining_admin_links = edition.reload.body.split("\n").map(&:strip).select {|line|
      line =~ /admin/
    }

    assert_equal [], remaining_admin_links
  end

  def assert_all_admin_links_erased(edition)
    remaining_admin_links = edition.reload.body.split("\n").map(&:strip).reject(&:blank?).each do |md_link|
      assert md_link =~ %r{^[^\[\]()]+$}
    end
  end

  def assert_correct_replacement_url(edition)
    assert edition.body.include?("policies/#{@policy.slug}/supporting-pages/#{@supporting_page.slug}")
  end
end
