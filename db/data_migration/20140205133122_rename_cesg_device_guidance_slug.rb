require 'gds_api/router'

OLD_SLUG = 'end-user-devices-security-guidance--2'
NEW_SLUG = 'end-user-devices-security-guidance'

document = Document.find_by_slug(OLD_SLUG)
document.update_attribute(:slug, NEW_SLUG)

router = GdsApi::Router.new(Plek.current.find('router-api'))
router.add_redirect_route("/government/collections/#{OLD_SLUG}",
                          'exact',
                          "/government/collections/#{NEW_SLUG}")
