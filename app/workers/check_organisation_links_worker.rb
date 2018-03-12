# Calls the Link Checker API to verify all links in public editions, either per organisation or not
class CheckOrganisationLinksWorker
  include Sidekiq::Worker
  ORGANISATION_EDITION_LIMIT = 500

  sidekiq_options queue: "link_checks"

  def perform(organisation_id)
    GovukStatsd.time('link-checking-debug.check-organisation-links-worker') do
      organisation = find_organisation(organisation_id)
      editions = public_editions(organisation)
      logger.info("[link-checking-debug][org_#{organisation_id}][job_#{self.jid}]: Requesting link checks for #{editions.count}")

      ignored = 0
      editions.each do |edition|
        if LinkCheckerApiService.has_links?(edition)
          LinkCheckerApiService.check_links(edition, callback)
        else
          ignored += 1
        end
      end
      logger.info("[link-checking-debug][org_#{organisation_id}][job_#{self.jid}]: Done requesting link checks for #{editions.count}, ignored #{ignored} of them")
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
