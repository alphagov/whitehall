require 'gds_api/maslow'

Whitehall.maslow = GdsApi::Maslow.new(Plek.new.external_url_for('maslow'))
