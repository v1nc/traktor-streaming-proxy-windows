# traktor-streaming-proxy-windows
*Allow Traktor DJ on windows to stream music from YouTube, Spotify, and Tidal by faking Beatport's API*

<img src="screenshot.png" align="right" width="250"></a>

**Note that running this software might violate copyright laws in your country. This repository is for educational purpose only. Use at your own risk**


This fork is based on [traktor-streaming-proxy v0.4.1](https://github.com/0xf4b1/traktor-streaming-proxy) and instructions in this [issue](https://github.com/0xf4b1/traktor-streaming-proxy/issues/13). Thanks to [@0xf4b1](https://github.com/0xf4b1) and [@radusuciu](https://github.com/radusuciu) for your work. New changes of v0.5 will be merged once I tested them successfully. You need to set up the docker image manually at the moment. Once I added a prebuild docker image, you will only need to start the docker container, trust the certificate and patch your `Traktor.exe`


Traktor DJ supports streaming of music tracks, but only from the Beatport and Beatsource services.
This project aims to integrate other streaming sources into Traktor DJ via Beatport Streaming.
It consists of an API server based on ktor which fakes some relevant parts of the Beatport API to serve custom content.

Currently, it supports YouTube Music (via NewPipe), Spotify, and Tidal with support for searching for music and browsing saved tracks and playlists.
In theory other streaming services or self-hosted sources will be possible to integrate as long as they serve music files in mp4a audio format, since Traktor refuses to load other formats (even though these formats are supported for local files).
As a workaround, an on-the-fly format conversion of the music files should be possible at some cost in quality and time.

As with Beatport streaming, Traktor does not allow to use the build-in recorder.

## How to Setup:
1. Install docker desktop [with WSL](https://docs.docker.com/desktop/features/wsl/)
2. Enable "Start Docker Desktop when you sign in to your computer" in the Docker Desktop settings to make it run at login
3. Start an ubuntu WSL shell (or your prefered distro)
4. Clone repo: `git clone https://github.com/v1nc/traktor-streaming-proxy-windows`
5. If you want to use Spotify or Tidal, add you credentials to `config.properties`. YouTube works without configuration
6. Create and start docker image:
```
cd traktor-streaming-proxy-windows
docker build -t traktor-streaming-proxy-windows .
docker run -d --name traktor-streaming-proxy-windows-container -p 80:80 -p 443:443 --restart always traktor-streaming-proxy-windows
```
7. Trust `server.crt` on your machine: For ubuntu wsl, go to `\\wsl.localhost\Ubuntu\home\username\traktor-streaming-proxy-windows\` in you explorer, click on `server.crt`, select *Install certificate*, select *Local computer*, click *Next*, select *All certificates* and choose *Trusted Root Certification Authorities*, then install the certificate
8. Patch `Traktor.exe` to make it accept the license (Use `patch_traktor.py` or see the notes below)
9. Run Traktor, go to *settings*, *streaming* and click *Login on Beatport*. If you just booted your device, wait a minute for the docker container to start. If you start Traktor before the container runs, you will need to click *Login to Beatport* again
10. Everything should work :)

# Notes
- if you don't want to use my prebuild certificate, you can run `cert/gen-cert.sh` and replace `server.crt` and `server.key` in the root directory before you build the docker image. Because the private key of my prebuild certificate is included in this repository, a man in the middle attacker could theoretically read and modify your traffic to the API if you run this on a network
- the `patch_traktor.py` script was only tested on Traktor version 4.11.23. If it does not work for you, you can patch the `Traktor.exe` manually:
  1. Download a hex editor like [hxd](https://mh-nexus.de/de/hxd/)
  2. Backup `C:\Program Files\Native Instruments\Traktor xx\Traktor.exe` and open it with your hex editor
  3. Search for `-----BEGIN PUBLIC KEY-----`. It should be the first occurrence, but verify it is the windows key listed [here](https://github.com/0xf4b1/traktor-streaming-proxy/issues/13#issuecomment-1742184706)
  4. Replace the key with the mac key listed [here](https://github.com/0xf4b1/traktor-streaming-proxy/issues/13#issuecomment-1742184706). Dots in the hex editor represent new lines, so the best way is to replace the key line per line, leaving the dots where they are
  5. Save the binary and copy it to `C:\Program Files\Native Instruments\Traktor xx\` if you moved it. Run it to verify it works
  6. Obviously you can not use the usual Beatport API with this version
- if you want to build the project yourself, uncomment the lines in the Dockerfile and save your github username and token to your env as `GITHUB_ACTOR` and `GITHUB_TOKEN`
