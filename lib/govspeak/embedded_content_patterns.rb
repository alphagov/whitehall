module Govspeak
  module EmbeddedContentPatterns
    CONTACT = /\[Contact:([0-9]+)\]/
    ADMIN_EDITION_PATH = %r{/admin/(?:#{Whitehall.edition_route_path_segments.join('|')})/(\d+)}
    ADMIN_ORGANISATION_CIP_PATH = %r{/admin/organisations/([\w-]+)/corporate_information_pages/(\d+)}
    ADMIN_WORLDWIDE_ORGANISATION_CIP_PATH = %r{/admin/legacy_worldwide_organisations/([\w-]+)/corporate_information_pages/(\d+)}
  end
end
