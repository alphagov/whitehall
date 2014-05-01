require 'gds_api/maslow'

Whitehall.maslow = GdsApi::Maslow.new(Plek.current.find('maslow'))
