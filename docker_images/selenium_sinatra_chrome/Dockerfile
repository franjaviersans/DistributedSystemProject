FROM selenium/standalone-chrome

LABEL authors=franjav


USER root


# skip installing gem documentation
RUN mkdir -p /usr/local/etc \
	&& { \
		echo 'install: --no-document'; \
		echo 'update: --no-document'; \
	} >> /usr/local/etc/gemrc

ENV RUBY_MAJOR 2.5-rc
ENV RUBY_VERSION 2.5.0-rc1
ENV RUBY_DOWNLOAD_SHA256 a479a1bce69b2cf656821f10104dcb8b426922b56d3d6cbdf48318842fae752c
ENV RUBYGEMS_VERSION 2.7.3
ENV BUNDLER_VERSION 1.16.1


# some of ruby's build scripts are written in ruby
#   we purge system ruby later to make sure our final image uses what we just built
# readline-dev vs libedit-dev: https://bugs.ruby-lang.org/issues/11869 and https://github.com/docker-library/ruby/issues/75
RUN set -ex \
	\
	&& apt-get update \
	&& apt-get install -y \
		autoconf \
		bison \
		bzip2 \
#		bzip2-dev \
		ca-certificates \
		coreutils \
		dpkg-dev dpkg \
		gcc \
#		gdbm-dev \
#		glib-dev \
		libc-dev \
		libffi-dev \
#		libressl \
#		libressl-dev \
		libssl-dev \
		zlib1g-dev \
		libxml2-dev \
		libxslt-dev \
#		linux-headers \
		make \
		ncurses-dev \
		procps \
#		readline-dev \
		ruby \
		tar \
#		xz \
#		yaml-dev \
#		zlib-dev \
	\
	&& wget -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz" \
	&& echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum -c - \
	\
	&& mkdir -p /usr/src/ruby \
	&& tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1 \
	&& rm ruby.tar.xz \
	\
	&& cd /usr/src/ruby \
	\
# hack in "ENABLE_PATH_CHECK" disabling to suppress:
#   warning: Insecure world writable dir
	&& { \
		echo '#define ENABLE_PATH_CHECK 0'; \
		echo; \
		cat file.c; \
	} > file.c.new \
	&& mv file.c.new file.c \
	\
	&& autoconf \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
# the configure script does not detect isnan/isinf as macros
	&& export ac_cv_func_isnan=yes ac_cv_func_isinf=yes \
	&& ./configure \
		--build="$gnuArch" \
		--disable-install-doc \
		--enable-shared \
	&& make -j "$(nproc)" \
	&& make install \
	\
	&& runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apt-get install  -y\
		bzip2 \
		ca-certificates \
		libffi-dev \
#		yaml-dev \
		procps \


	&& cd / \
	&& rm -r /usr/src/ruby \
	\
	&& gem update --system "$RUBYGEMS_VERSION" \
	&& gem install bundler --version "$BUNDLER_VERSION" --force

# install things globally, for great justice
# and don't create ".bundle" in all our apps
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
	BUNDLE_BIN="$GEM_HOME/bin" \
	BUNDLE_SILENCE_ROOT_WARNING=1 \
	BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH
RUN mkdir -p "$GEM_HOME" "$BUNDLE_BIN" \
	&& chmod 777 "$GEM_HOME" "$BUNDLE_BIN"




#to run sinatra server
ENV RACK_ENV production
ENV MAIN_APP_FILE web.rb

RUN mkdir -p /usr/src/app

COPY Gemfile /usr/src/app

WORKDIR /usr/src/app

RUN bundle install --without development test

COPY startup.sh /



EXPOSE 80
EXPOSE 4444


CMD ["/bin/bash", "/startup.sh"]
