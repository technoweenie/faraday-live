# https://hub.docker.com/_/ruby
FROM ruby:2.6.2 as build
ENV LANG C.UTF-8
WORKDIR /app
COPY Gemfile ./
RUN bundle install --without development test -j4 --retry 3 \
  # Remove unneeded files (cached *.gem, *.o, *.c)
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -name "*.c" -delete \
  && find /usr/local/bundle/gems/ -name "*.o" -delete

# set up Gemfile for final docker stage
RUN echo "gem 'faraday', git: 'https://github.com/lostisland/faraday'," >> Gemfile
RUN echo "  ref: ENV['FARADAY_REF'], require: 'faraday'" >> Gemfile

FROM ruby:2.6.2
ENV LANG C.UTF-8
WORKDIR /app
COPY . ./
COPY --from=build /usr/local/bundle/ /usr/local/bundle/
COPY --from=build /app/Gemfile .
RUN bundle install

CMD ./run.sh
