FROM ubuntu:18.04 as build-dep

# Use bash for the shell
SHELL ["bash", "-c"]

# Install Node
ENV NODE_VER="10.15.3"
RUN	echo "Etc/UTC" > /etc/localtime && \
	apt update && \
	apt -y dist-upgrade && \
	apt -y install wget make gcc g++ python && \
	apt install -y git-core curl build-essential openssl libssl-dev && \
	curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
	apt -y install nodejs && \
	node -v && \
	cd ~
# Install jemalloc
ENV JE_VER="5.1.0"
RUN apt update && \
	apt -y install autoconf && \
	cd ~ && \
	wget https://github.com/jemalloc/jemalloc/archive/$JE_VER.tar.gz && \
	tar xf $JE_VER.tar.gz && \
	cd jemalloc-$JE_VER && \
	./autogen.sh && \
	./configure --prefix=/opt/jemalloc && \
	make -j$(nproc) > /dev/null && \
	make install_bin install_include install_lib

# Install ruby
ENV RUBY_VER="2.6.7"
ENV CPPFLAGS="-I/opt/jemalloc/include"
ENV LDFLAGS="-L/opt/jemalloc/lib/"
RUN apt update && \
	apt -y install build-essential && \
	apt -y install bison libyaml-dev libgdbm-dev libreadline-dev && \
	apt -y install libncurses5-dev libffi-dev zlib1g-dev libssl-dev && \
	cd ~ && \
	curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash -
ENV PATH="${PATH}:/root/.rbenv/bin"
# Installing rvm 
RUN apt install -qy procps curl ca-certificates gnupg2 --no-install-recommends

RUN gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN curl -sSL https://get.rvm.io | bash -s
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install 2.6.7"

# # Continue Ruby Installation
# Run	cd ~ && \
# 	echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
# 	source ~/.bashrc && \
# 	rbenv install --verbose $RUBY_VER && \
# 	ruby -v
 	

# Install package dependency managers
RUN npm install -g yarn && \
	gem install bundler && \
	apt update && \
	apt -y install git libicu-dev libidn11-dev \
	libpq-dev libprotobuf-dev protobuf-compiler

COPY Gemfile* package.json yarn.lock /opt/gabsocial/

# Install application dependencies
RUN cd /opt/gabsocial && \
	bundle install -j$(nproc) --deployment --without development test && \
	yarn install --pure-lockfile

FROM ubuntu:18.04

# Copy over all the langs needed for runtime
COPY --from=build-dep /opt/node /opt/node
COPY --from=build-dep /opt/ruby /opt/ruby
COPY --from=build-dep /opt/jemalloc /opt/jemalloc

# Add more PATHs to the PATH
ENV PATH="${PATH}:/opt/ruby/bin:/opt/node/bin:/opt/gabsocial/bin"

# Create the gabsocial user
ARG UID=991
ARG GID=991
RUN apt update && \
	echo "Etc/UTC" > /etc/localtime && \
	ln -s /opt/jemalloc/lib/* /usr/lib/ && \
	apt -y dist-upgrade && \
	apt install -y vim whois wget && \
	addgroup --gid $GID gabsocial && \
	useradd -m -u $UID -g $GID -d /opt/gabsocial gabsocial && \
	echo "gabsocial:`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -s -m sha-256`" | chpasswd

# Install gabsocial runtime deps
RUN apt -y --no-install-recommends install \
	  libssl1.1 libpq5 imagemagick ffmpeg \
	  libicu60 libprotobuf10 libidn11 libyaml-0-2 \
	  file ca-certificates tzdata libreadline7 && \
	apt -y install gcc && \
	ln -s /opt/gabsocial /gabsocial && \
	gem install bundler && \
	rm -rf /var/cache && \
	rm -rf /var/lib/apt/lists/*

# Add tini
ENV TINI_VERSION="0.18.0"
ENV TINI_SUM="12d20136605531b09a2c2dac02ccee85e1b874eb322ef6baf7561cd93f93c855"
ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini /tini
RUN echo "$TINI_SUM tini" | sha256sum -c -
RUN chmod +x /tini

# Copy over masto source, and dependencies from building, and set permissions
COPY --chown=gabsocial:gabsocial . /opt/gabsocial
COPY --from=build-dep --chown=gabsocial:gabsocial /opt/gabsocial /opt/gabsocial

# Run masto services in prod mode
ENV RAILS_ENV="production"
ENV NODE_ENV="production"

# Tell rails to serve static files
ENV RAILS_SERVE_STATIC_FILES="true"

# Set the run user
USER gabsocial

# Precompile assets
RUN cd ~ && \
	OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder rails assets:precompile && \
	yarn cache clean

# Set the work dir and the container entry point
WORKDIR /opt/gabsocial
ENTRYPOINT ["/tini", "--"]
