# https://hub.docker.com/_/ruby
FROM ruby:2.6.2 as build
ENV LANG C.UTF-8
WORKDIR /app

# install all non-git gems
RUN gem install bundler -v '~> 2.0.1' --no-document

COPY Gemfile .
COPY Gemfile.lock .

RUN bundle install --without development test -j4 --retry 3

# install just the non-git gems. These will change more frequently.
RUN echo "gem 'faraday', git: 'https://github.com/lostisland/faraday'," >> Gemfile
ARG faraday_gem_ref=master
RUN echo "  ref: '$faraday_gem_ref', require: 'faraday'" >> Gemfile

RUN echo "gem 'faraday-http', git: 'https://github.com/lostisland/faraday-http'," >> Gemfile
ARG faraday_http_gem_ref=master
RUN echo "  ref: '$faraday_http_gem_ref', require: 'faraday/http'" >> Gemfile

RUN echo "gem 'socksify', git: 'https://github.com/astro/socksify-ruby'," >> Gemfile
ARG socksify_gem_ref=master
RUN echo "  ref: '$socksify_gem_ref'" >> Gemfile

RUN bundle install \
  # Remove unneeded files (cached *.gem, *.o, *.c)
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -name "*.c" -delete \
  && find /usr/local/bundle/gems/ -name "*.o" -delete

COPY run.sh .
COPY ./spec ./

CMD ./run.sh
