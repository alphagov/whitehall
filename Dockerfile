FROM ruby:2.4.2
RUN apt-get update -qq && apt-get upgrade -y

RUN apt-get install -y build-essential nodejs && apt-get clean

ENV GOVUK_APP_NAME whitehall
ENV GOVUK_CONTENT_SCHEMAS_PATH /govuk-content-schemas
ENV PORT 3020
ENV REDIS_HOST redis
ENV RAILS_ENV development
ENV DATABASE_URL mysql2://root:root@mysql/whitehall_development
ENV TEST_DATABASE_URL mysql2://root:root@mysql/whitehall_test

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
ADD .ruby-version $APP_HOME/
RUN bundle install

ADD . $APP_HOME

RUN GOVUK_ASSET_ROOT=https://assets.publishing.service.gov.uk \
  GOVUK_APP_DOMAIN=www.gov.uk \
  GOVUK_APP_DOMAIN_EXTERNAL=www.gov.uk \
  RAILS_ENV=production \
  bundle exec rails assets:precompile

HEALTHCHECK CMD curl --silent --fail localhost:$PORT/healthcheck || exit 1

CMD bundle exec foreman run web
