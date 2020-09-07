# syntax=docker/dockerfile:experimental

FROM ruby:2.5.8
ENV LANG C.UTF-8
RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    imagemagick

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install yarn

ENV APP_ROOT /app
WORKDIR ${APP_ROOT}

COPY ./Gemfile ${APP_ROOT}/
COPY ./Gemfile.lock ${APP_ROOT}/

RUN bundle install --jobs 4 --retry 5

COPY ./package.json ${APP_ROOT}/
COPY ./yarn.lock ${APP_ROOT}/

RUN yarn install

COPY . .

EXPOSE 3000

WORKDIR ${APP_ROOT}

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]