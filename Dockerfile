ARG ruby_version=3.1.2
ARG base_image=ghcr.io/alphagov/govuk-ruby-base:$ruby_version
ARG builder_image=ghcr.io/alphagov/govuk-ruby-builder:$ruby_version

FROM $builder_image AS builder

ENV ASSETS_PREFIX=/assets/whitehall \
    JWT_AUTH_SECRET=unused_yet_required

WORKDIR $APP_HOME
COPY Gemfile Gemfile.lock .ruby-version ./
# TODO: remove chmod workaround once https://github.com/mikel/mail/issues/1489 is fixed.
RUN bundle install && chmod -R o+r "${BUNDLE_PATH}"
COPY package.json yarn.lock ./
RUN yarn install --production --frozen-lockfile --non-interactive --link-duplicates
COPY . ./
RUN bundle exec bootsnap precompile --gemfile .
RUN bundle exec rails assets:precompile && rm -fr log


FROM $base_image

ENV ASSETS_PREFIX=/assets/whitehall \
    GOVUK_APP_NAME=whitehall \
    GOVUK_UPLOADS_ROOT=/uploads

RUN install_packages imagemagick unzip

WORKDIR $APP_HOME
COPY --from=builder /usr/bin/node* /usr/bin/
COPY --from=builder /usr/lib/node_modules/ /usr/lib/node_modules/
COPY --from=builder $BUNDLE_PATH/ $BUNDLE_PATH/
COPY --from=builder $BOOTSNAP_CACHE_DIR/ $BOOTSNAP_CACHE_DIR/
COPY --from=builder $APP_HOME ./

USER app
CMD ["puma"]
