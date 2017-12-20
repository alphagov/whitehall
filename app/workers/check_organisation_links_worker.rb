# Calls the Link Checker API to verify all links in public editions, either per organisation or not
class CheckOrganisationLinksWorker
  include Sidekiq::Worker
  ORGANISATION_EDITION_LIMIT = 1000

  sidekiq_options queue: "link_checks"

  def perform(organisation_id)
    organisation = find_organisation(organisation_id)

    public_editions(organisation).each do |edition|
      next unless LinkCheckerApiService.has_links?(edition)

      LinkCheckerApiService.check_links(edition, callback)
    end
  end

private

  def find_organisation(organisation_id)
    Organisation.find(organisation_id)
  end

  def public_editions(organisation)
    Edition.includes(:link_check_reports).publicly_visible.with_translations.in_organisation(organisation).order('link_checker_api_reports.updated_at').limit(ORGANISATION_EDITION_LIMIT)
  end

  def callback
    Whitehall::UrlMaker.new(host: Plek.find('whitehall-admin')).admin_link_checker_api_callback_url
  end
end
