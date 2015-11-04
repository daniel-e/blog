FROM ubuntu:15.10

# requirements:
# authorized_keys
# id_rsa
# id_rsa.pub

RUN apt-get update
RUN apt-get install -y ruby vim aptitude ruby2.1-dev build-essential zlibc zlib1g-dev ruby-execjs
RUN apt-get install -y less unzip wget screen git net-tools openssh-server telnet sudo
RUN apt-get install -y python-pygments
RUN gem install bundler

RUN echo "zz ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN mkdir /var/run/sshd

RUN useradd -d /home/zz -m -p pwd -s /bin/bash zz
ADD authorized_keys /home/zz/.ssh/
ADD id_rsa /home/zz/.ssh/
ADD id_rsa.pub /home/zz/.ssh/
RUN echo "alias l='ls -l'" >> /home/zz/.bashrc
RUN echo "alias ..='cd ..'" >> /home/zz/.bashrc
RUN chown -R zz:zz /home/zz

WORKDIR /home/zz
USER zz
RUN git config --global user.email "git.daniele@gmail.com"
RUN git config --global user.name "daniel-e"

# install some packages required for Jekyll
USER root
RUN mkdir -p /tmp/dummy
WORKDIR /tmp/dummy
RUN echo "source 'https://rubygems.org'" > Gemfile
RUN echo "gem 'github-pages'" >> Gemfile
RUN bundle update

CMD ["/usr/sbin/sshd", "-D"]
