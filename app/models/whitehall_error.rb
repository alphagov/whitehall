# Base class for Whitehall-specific domain errors.
#
# We rescue WhitehallError in places where we want to handle
# expected business/application failures gracefully, without also
# swallowing unexpected framework or programming errors.
#
# Avoid rescuing StandardError directly unless we genuinely intend
# to catch any application exception, including Rails, ActiveRecord,
# or Ruby runtime errors.
#
# Any error inheriting from WhitehallError is considered part of
# Whitehall's intentional public error surface.
class WhitehallError < StandardError
end
