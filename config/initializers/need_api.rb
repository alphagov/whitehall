require 'gds_api/need_api'

Whitehall.need_api = GdsApi::NeedApi.new(Plek.new.find('need-api'),
                                         bearer_token: "XXXXXXXXXX")
