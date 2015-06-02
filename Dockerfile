# TODO Hacer que delayed_job suba como servicio

FROM phusion/passenger-ruby21:0.9.12
MAINTAINER Patricio Bruna <pbruna@itlinux.cl>

RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/service/sshd/down
RUN mkdir -p /home/app/carterapp
RUN mkdir -p /home/app/carterapp/tmp

WORKDIR /home/app/carterapp
ADD Gemfile /home/app/carterapp/
ADD Gemfile.lock /home/app/carterapp/
RUN bundle install

ADD config/pbruna-ssh-key.pub /tmp/your_key
RUN cat /tmp/your_key >> /root/.ssh/authorized_keys && rm -f /tmp/your_key
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Aquí para que no moleste al cache
ADD . /home/app/carterapp
ADD config/carterapp-nginx.conf /etc/nginx/sites-enabled/carterapp-nginx.conf
ADD config/nginx-env.conf /etc/nginx/main.d/nginx-env.conf


ENV RAILS_ENV production

# RUN rake db:migrate
# RUN rake db:seed
RUN rake assets:precompile
# RUN rake assets:sync
RUN rake tmp:create
RUN rake tmp:clear
RUN cp -a /home/app/carterapp/vendor/assets/stylesheets/homer /home/app/carterapp/public/assets/
RUN chown 9999:9999 -R /home/app/carterapp

CMD ["/sbin/my_init"]
