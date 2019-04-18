# https://hub.docker.com/_/ruby
FROM ruby:2.6.2 as build
ENV LANG C.UTF-8
WORKDIR /app
COPY . ./

# install all non-git gems
RUN gem install bundler -v '~> 2.0.1' --no-document
RUN bundle install --without development test -j4 --retry 3

# install just the non-git gems. These will change more frequently.
RUN echo "gem 'faraday', git: 'https://github.com/lostisland/faraday'," >> Gemfile
RUN echo "  ref: ENV['FARADAY_REF'], require: 'faraday'" >> Gemfile

RUN bundle install \
  # Remove unneeded files (cached *.gem, *.o, *.c)
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -name "*.c" -delete \
  && find /usr/local/bundle/gems/ -name "*.o" -delete

CMD ./run.sh
