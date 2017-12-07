# Calls the Link Checker API to verify all links in public editions, either per organisation or not
class CheckOrganisationLinksWorker
  include Sidekiq::Worker

  sidekiq_options queue: "link_checks"

  def perform(organisation_id)
    organisation = find_organisation(organisation_id)

    public_editions(organisation).find_each do |edition|
      next unless LinkCheckerApiService.has_links?(edition)

      LinkCheckerApiService.check_links(edition, callback)
    end
  end

private

  def find_organisation(organisation_id)
    Organisation.find(organisation_id)
  end

  def public_editions(organisation)
    Edition.publicly_visible.with_translations.in_organisation(organisation)
  end

  def callback
    Whitehall::UrlMaker.new(host: Plek.find('whitehall-admin')).admin_link_checker_api_callback_url
  end
end
