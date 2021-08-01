# pitrtl - Raspberry PI RTL SDR monitor
# Fri Jul 30 13:54:38 PDT 2021

This documents implementing an RTL SDR monitor on a Raspberry PI Zero W.


Goal:
- low cost
- feed data to remote influxdb
- use telegraf to manage influxdb server outages

Hardware:
- Raspberry PI Zero W
- Nooelec NESDR Mini 
- 5V Mini-UPS


## Pi Zero W Monitor

### rtl_433

Use rtl_433 to capture data, forward to influx://localhost:8086

- -H 120 - two minute hop time between frequencies
- -f 433.92M - standard 433 Mhz frequency
- -f 915M - standard 915 Mhz frequence


```
ExecStart=/usr/local/bin/rtl_433 -H 120 -f 433.92M -f 915M -F kv -F influx://localhost:8086/write?db=rtl_433
```

### telegraf

Started in systemd service file.

```
ExecStart=/usr/bin/telegraf -config /etc/telegraf/telegraf.conf 
```

Conf.

```
[[inputs.influxdb_listener]]
  ## Address and port to host InfluxDB listener on
  service_address = ":8086"

  ## maximum duration before timing out read of the request
  read_timeout = "10s"
  ## maximum duration before timing out write of the response
  write_timeout = "10s"

  ## Maximum allowed HTTP request body size in bytes.
  ## 0 means to use the default of 32MiB.
  max_body_size = "32MiB"

```

```
# Configuration for sending metrics to InfluxDB
[[outputs.influxdb]]
  ## The full HTTP or UDP URL for your InfluxDB instance.
  ##
  ## Multiple URLs can be specified for a single cluster, only ONE of the
  ## urls will be written to each interval.
  # urls = ["unix:///var/run/influxdb.sock"]
  # urls = ["udp://127.0.0.1:8089"]
  urls = ["http://influx4.wimsey.co:8086"]

  ## The target database for metrics; will be created as needed.
  ## For UDP url endpoint database needs to be configured on server side.
  # database = "telegraf"
  database = "rtl_433"

  ## The value of this tag will be used to determine the database.  If this
  ## tag is not set the 'database' option is used as the default.
  # database_tag = ""

```


