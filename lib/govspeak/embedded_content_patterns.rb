module Govspeak
  module EmbeddedContentPatterns
    CONTACT = /\[Contact\:([0-9]+)\]/.freeze
    ADMIN_EDITION_PATH = %r{/admin/(?:#{Whitehall.edition_route_path_segments.join('|')})/(\d+)}.freeze
    ADMIN_ORGANISATION_CIP_PATH = %r{/admin/organisations/([\w-]+)/corporate_information_pages/(\d+)}.freeze
    ADMIN_WORLDWIDE_ORGANISATION_CIP_PATH = %r{/admin/worldwide_organisations/([\w-]+)/corporate_information_pages/(\d+)}.freeze
  end
end
