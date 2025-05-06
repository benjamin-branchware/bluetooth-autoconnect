# bluetooth-autoconnect
Some devices don't seem to want to connect when the bluetooth.service starts. I've found that peripherals like mice connect just fine, perhaps because they are actively seeking a new connection. However, devices such as headphones which are often already connected to another device will not switch to my Linux session (it isn't "greedy" like Windows).

I want to be able to specify a file of Bluetooth MACs that I _always_ want to force-connect on login. This service does just that.

Specify the devices you want to force-connect in `~/.config/bluetooth/autoconnect`:

```
# My Sony headphones
AC:80:0A:A3:41:29
```

Place the service file under `~/.config/systemd/user/`, then reload the user daemon with `systemctl --user daemon-reload`.
Place the script under `~/.local/bin/`.
Finally, enable and start the service with `systemctl --user enable --now bluetooth-device-autoconnect.service`.
