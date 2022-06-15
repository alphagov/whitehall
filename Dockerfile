# (unless we decide to use Bitnami instead)
ARG base_image=ruby:3.0.4

FROM $base_image AS builder
# This image is only intended to be able to run this app in a production RAILS_ENV
ENV RAILS_ENV=production

# TODO: have a separate build image which already contains the build-only deps.

# Add yarn to apt sources
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qy && \
    apt-get upgrade -y && \
    apt-get install -y build-essential nodejs yarn && \
    apt-get clean
RUN mkdir /app
WORKDIR /app
COPY Gemfile Gemfile.lock .ruby-version package.json yarn.lock /app/
RUN bundle config set deployment 'true' && \
    bundle config set without 'development test' && \
    bundle install --jobs 4 --retry=2
RUN yarn install --production --frozen-lockfile
COPY . /app
# TODO: We probably don't want assets in the image; remove this once we have a proper deployment process which uploads to (e.g.) S3.
RUN GOVUK_ASSET_ROOT=https://assets.publishing.service.gov.uk \
  GOVUK_APP_DOMAIN=www.gov.uk \
  GOVUK_WEBSITE_ROOT=www.gov.uk \
  GOVUK_APP_DOMAIN_EXTERNAL=www.gov.uk \
  JWT_AUTH_SECRET=secret \
  bundle exec rake assets:precompile

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
CMD GOVUK_PROMETHEUS_EXPORTER=true bundle exec puma
