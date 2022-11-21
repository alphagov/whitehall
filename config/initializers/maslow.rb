require "gds_api/maslow"

Whitehall.maslow = GdsApi::Maslow.new(Plek.external_url_for("maslow"))
