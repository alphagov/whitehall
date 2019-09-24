ebola_response = TopicalEvent.friendly.find("ebola-government-response")

old_url = ebola_response.search_link
ebola_response.remove_from_search_index

ebola_response.update_attribute(:slug, "ebola-virus-government-response")

ebola_response.update_in_search_index
new_url = ebola_response.search_link

require "gds_api/router"
router = GdsApi::Router.new(Plek.find("router-api"))
router.add_redirect_route(old_url, "exact", new_url)
