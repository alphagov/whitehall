class ClassificationsController < PublicFacingController
  enable_request_formats show: [:atom]

  include CacheControlHelper
end
