FROM ruby:2.6.6
RUN apt-get update -qq && apt-get upgrade -y
RUN apt-get install -y build-essential nodejs && apt-get clean
RUN gem install foreman

# This image is only intended to be able to run this app in a production RAILS_ENV
ENV RAILS_ENV production

ENV GOVUK_APP_NAME whitehall
ENV GOVUK_CONTENT_SCHEMAS_PATH /govuk-content-schemas
ENV PORT 3020
ENV DATABASE_URL mysql2://root:root@mysql/whitehall_development

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
ADD .ruby-version $APP_HOME/
RUN bundle config set deployment 'true'
RUN bundle config set without 'development test'
RUN bundle install --jobs 4

ADD . $APP_HOME

RUN GOVUK_ASSET_ROOT=https://assets.publishing.service.gov.uk \
  GOVUK_APP_DOMAIN=www.gov.uk \
  GOVUK_WEBSITE_ROOT=www.gov.uk \
  GOVUK_APP_DOMAIN_EXTERNAL=www.gov.uk \
  bundle exec rake shared_mustache:compile assets:precompile

HEALTHCHECK CMD curl --silent --fail localhost:$PORT/healthcheck/ready || exit 1

CMD foreman run web
