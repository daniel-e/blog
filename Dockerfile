FROM ubuntu:16.10

RUN apt-get update
RUN apt-get install -y ruby vim aptitude ruby2.3-dev ruby-execjs python-pygments unzip zlibc zlib1g-dev
RUN apt-get install -y build-essential ruby-pygments screen telnet
RUN gem install bundler

