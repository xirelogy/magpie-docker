#!/bin/sh

# Initialize openrc
openrc
touch /run/openrc/softlevel

# Start the services
/etc/init.d/php-fpm81 start
/etc/init.d/nginx start

if [ "$MAGPIE_RUN_BACKGROUND" == "1" ]; then
  /etc/init.d/supervisord start
fi

# Install signal handler
trap term_handler TERM
term_handler()
{
  echo "Caught SIGTERM..."
  if [ "$MAGPIE_RUN_BACKGROUND" == "1" ]; then
    /etc/init.d/supervisord stop
  fi
  /etc/init.d/nginx stop
  /etc/init.d/php-fpm81 stop
  
  echo "All done, goodbye"
  exit 0
}

# Loop and wait
echo "Loop and wait for TERM signal..."
while :
do
  sleep 1
done

