require 'gds_api/need_api'

Whitehall.need_api = GdsApi::NeedApi.new(Plek.find('need-api'),
                                         bearer_token: "XXXXXXXXXX")
