FROM ruby:2.2.3
MAINTAINER Gavin DeSchutter "gavin.deschutter@mac.com"
RUN apt-get update  -qq && \
    apt-get install -y build-essential && \
    apt-get install -y nodejs

CMD ["/bin/bash"]

# Environment Variables
ENV APP_HOME /srv/citygram
ENV LANG en_us.utf8
ENV LC_ALL en_us.utf8

# Install gems
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile $APP_HOME/

# Upload source
COPY . $APP_HOME
WORKDIR $APP_HOME

RUN bundle install

# Start server
ENV PORT 5000
EXPOSE $PORT

ENTRYPOINT ["bin/entry"]