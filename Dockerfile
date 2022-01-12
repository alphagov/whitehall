# TODO: make this default to govuk-ruby once it's being pushed somewhere public
# (unless we decide to use Bitnami instead)
ARG base_image=ruby:2.6.6

FROM $base_image AS builder
# This image is only intended to be able to run this app in a production RAILS_ENV
ENV RAILS_ENV=production
# TODO: have a separate build image which already contains the build-only deps.
RUN apt-get update -qy && \
    apt-get upgrade -y && \
    apt-get install -y build-essential nodejs
RUN mkdir /app
WORKDIR /app
COPY Gemfile Gemfile.lock .ruby-version /app/
RUN bundle config set deployment 'true' && \
    bundle config set without 'development test' && \
    bundle install --jobs 4 --retry=2
COPY . /app
# TODO: We probably don't want assets in the image; remove this once we have a proper deployment process which uploads to (e.g.) S3.
RUN GOVUK_ASSET_ROOT=https://assets.publishing.service.gov.uk \
  GOVUK_APP_DOMAIN=www.gov.uk \
  GOVUK_WEBSITE_ROOT=www.gov.uk \
  GOVUK_APP_DOMAIN_EXTERNAL=www.gov.uk \
  bundle exec rake shared_mustache:compile assets:precompile

FROM $base_image
ENV RAILS_ENV=production GOVUK_APP_NAME=whitehall
# TODO: include nodejs in the base image (govuk-ruby).
# TODO: apt-get upgrade in the base image
RUN apt-get update -qy && \
    apt-get upgrade -y && \
    apt-get install -y nodejs
WORKDIR /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app ./
CMD bundle exec puma
