require 'gds_api/need_api'

Whitehall.need_api = GdsApi::NeedApi.new(Plek.current.find('need-api'),
                                         token: "XXXXXXXXXX")
