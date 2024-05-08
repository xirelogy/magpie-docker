# docker container for magpie hosting

This is a all-in-one container to host and run projects developed using the [PHP-magpie](https://github.com/xirelogy/magpie-core) framework.


### Features

- Slim base image using alpine
- PHP 8.1 (fpm) and nginx
- composer
- background processes (using supervisord/cron)


### Usage

To get the image:

```shell
sudo docker pull xirelogy/magpie-host
```

To run the container:

```shell
sudo docker run -d -p 80:80 -v /path-to-project:/app xirelogy/magpie-host
```

whereas `/path-to-project` should be replaced with the actual local path to the project.


### Supported environment variables

- `TZ`: The specific timezone where the container should use (default: `UTC`)
- `MAGPIE_RUN_BACKGROUND`: 1 means *true* and 0 means *false*; if background processes (queues, schedules) should run (default: `1`)
