# Frigate configuration

[Frigate](https://github.com/blakeblackshear/frigate) could be configured without go2rtc,
but the recommended way is to use [go2rtc](https://github.com/AlexxIT/go2rtc/) to reduce number of connections to cameras.

go2rtc will re-stream camera stream(s) and Frigate will connect to it instead of camera directly.

## Env substitution for go2rtc

When Frigate generates config for `go2rtc`, it substitutes environment variable templates with env values.

Such envs [should start](https://github.com/blakeblackshear/frigate/blob/0c92c3ccfa9bf3da2c5145c40f24c59d46e0921b/docker/main/rootfs/usr/local/go2rtc/create_config.py#L25C74-L25C82) with the `FRIGATE_` prefix.

Example Frigate config:

```yaml
go2rtc:
  streams:
    hall_main:
      - rtsp://admin:{FRIGATE_PW_HALL}@ipcamera.sib.li:554/Preview_01_main
```

Note: Frigate variable template is defined with brackets, and not with bash syntax (`${FRIGATE_PW_HALL}`).

To check generated config, use:

```bash
docker exec -it frigate bash
cat /dev/shm/go2rtc.yaml
```

Related section should contain substituted string (assuming you set or proxied the `FRIGATE_PW_HALL` env in the `docker-compose.yaml`):

```yaml
streams:
  hall_main:
  - rtsp://admin:YOUR_SECRET_PASSWORD@ipcamera.sib.li:554/Preview_01_main
```

But `go2rtc` also supports environment variables substitution natively (it even supports [systemd credential files](https://systemd.io/CREDENTIALS/)).

`go2rtc` expects variable to be defined with bash syntax: `username: ${RTSP_USER:admin}` (if RTSP_USER is not set, admin will be substituted).

If you don't want Frigate to substitute variable and want `go2rtc` to get it from env instead, use double brackets in the Frigate config:

```yaml
streams:
  dome1_main:
    - rtsp://admin:${{FRIGATE_PW_DOME1}}@ipcamera.sib.li:554/cam/realmonitor?channel=1&subtype=0
```

It will translate to `${FRIGATE_PW_DOME1}` in the `/dev/shm/go2rtc.yaml` and go2rtc will look for env with that name.

Note: If no environment variable is set, then the string will be used as-is.

More on go2rtc configuration: https://github.com/AlexxIT/go2rtc/blob/master/internal/app/README.md

Same with rtsp restream password, you could use either:

```yaml
go2rtc:
  rtsp:
    username: admin
    password: {FRIGATE_RESTREAM_PASSWORD}
```

or:

```yaml
go2rtc:
  rtsp:
    username: admin
    password: ${{FRIGATE_RESTREAM_PASSWORD}}
```

To check restream is working, use [VLC](https://www.videolan.org/vlc/) or ffprobe (assuming `docker-compose.yaml` exposes 8554 port from the frigate container):

```bash
ffprobe -hide_banner -rtsp_transport tcp "rtsp://admin:${RTSP_PW_RESTREAM}@127.0.0.1:8554/door_main"
```

For the WebRTC candidates list, use this:

```yaml
go2rtc:
  webrtc:
    candidates:
      # Bind specific ip for WebRTC
      - ${FRIGATE_IP_WEBRTC}:8555
```

At some point you will probably want to just run `go2rtc` outside of the frigate container and provide it's config manually.

```bash
mkdir go2rtc
curl -L https://github.com/AlexxIT/go2rtc/releases/download/v1.9.9/go2rtc_linux_arm64 --output go2rtc
chmod +x go2rtc
touch go2rtc.yaml
./go2rtc -d
```