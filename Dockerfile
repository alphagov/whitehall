ARG ruby_version=3.0.4
ARG base_image=ruby:$ruby_version-slim-bullseye
ARG gem_home=/usr/local/bundle

FROM $base_image AS builder
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG gem_home
ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=1 \
    NODE_ENV=production \
    GEM_HOME=$gem_home \
    BUNDLE_PATH=$gem_home \
    BUNDLE_BIN=$gem_home/bin \
    PATH=$gem_home/bin:$PATH \
    BUNDLE_WITHOUT="development test cucumber" \
    BOOTSNAP_CACHE_DIR=/var/cache/bootsnap

# TODO: set these in the builder image.
ENV BUNDLE_IGNORE_MESSAGES=1 \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_JOBS=12 \
    MAKEFLAGS=-j12

ENV ASSETS_PREFIX=/assets/whitehall \
    GOVUK_UPLOADS_ROOT=/tmp/uploads \
    GOVUK_APP_DOMAIN=unused \
    GOVUK_WEBSITE_ROOT=unused \
    JWT_AUTH_SECRET=unused

# TODO: have an up-to-date builder image and stop running apt-get upgrade.
# TODO: have a separate builder image which already contains the build-only deps.
RUN apt-get update -qy && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        g++ make libc-dev curl yarnpkg libmariadb-dev-compat && \
    ln -s /usr/bin/yarnpkg /usr/bin/yarn

RUN mkdir /app && \
    ln -fs /tmp /app/tmp && \
    ln -fs /tmp /app/asset-manager-tmp && \
    ln -fs /tmp /home/app
WORKDIR /app
RUN echo 'install: --no-document' >> /etc/gemrc && gem update --system --silent && gem cleanup
COPY Gemfile Gemfile.lock .ruby-version /app/
# Make the installed version of bundler match the one that wrote Gemfile.lock.
RUN gem install bundler \
        --silent \
        --version "$(sed -e '1,/BUNDLED WITH/d' Gemfile.lock | grep -Eo '[0-9.]+')" && \
    bundle install
COPY package.json yarn.lock /app/
RUN yarnpkg install --production --frozen-lockfile --non-interactive --link-duplicates
COPY . /app
<<<<<<< HEAD
RUN bundle exec bootsnap precompile --gemfile .
RUN bundle exec rails assets:precompile && rm -fr log

=======
# TODO: We probably don't want assets in the image; remove this once we have a proper deployment process which uploads to (e.g.) S3.
RUN GOVUK_ASSET_ROOT=https://assets.publishing.service.gov.uk \
  GOVUK_APP_DOMAIN=www.gov.uk \
  GOVUK_WEBSITE_ROOT=www.gov.uk \
  GOVUK_APP_DOMAIN_EXTERNAL=www.gov.uk \
  JWT_AUTH_SECRET=secret \
  bundle exec rake assets:precompile
<<<<<<< HEAD
>>>>>>> ed92bb8b4c22b7b560b7a0c143fddd04d8b8a5ae
=======
>>>>>>> ed92bb8b4c22b7b560b7a0c143fddd04d8b8a5ae

FROM $base_image

# TODO: set these in the base image.
ARG gem_home
ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=1 \
    NODE_ENV=production \
    GEM_HOME=/usr/local/bundle \
    BUNDLE_PATH=$gem_home \
    BUNDLE_BIN=$gem_home/bin \
    PATH=$gem_home/bin:$PATH \
    BUNDLE_WITHOUT="development test cucumber" \
    BOOTSNAP_CACHE_DIR=/var/cache/bootsnap \
    GOVUK_PROMETHEUS_EXPORTER=true

ENV ASSETS_PREFIX=/assets/whitehall \
    GOVUK_APP_NAME=whitehall \
    GOVUK_UPLOADS_ROOT=/tmp/uploads

# TODO: have an up-to-date base image and stop running apt-get here.
RUN apt-get update -qy && \
    apt-get upgrade -y --purge && \
    apt-get install -y --no-install-recommends libmariadb3 && \
    apt-get clean && \
    rm -fr /var/lib/apt/lists

WORKDIR /app
RUN mkdir -p /app && ln -fs /tmp /app/tmp && ln -fs /tmp /home/app && \
    echo 'IRB.conf[:HISTORY_FILE] = "/tmp/irb_history"' > irb.rc
COPY --from=builder /usr/bin/node* /usr/bin/
COPY --from=builder /usr/lib/nodejs/ /usr/lib/nodejs/
COPY --from=builder /usr/share/nodejs/ /usr/share/nodejs/
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app ./

RUN groupadd -g 1001 app && \
    useradd -u 1001 -g app app
USER 1001
CMD ["bundle", "exec", "puma"]
