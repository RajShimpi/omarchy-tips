# Tip of the Day

One short tip a day for Omarchy: window management, screenshots,
notifications, the terminal, tmux, Neovim and git, mixed with tips made
from your own keybindings.

Plugin id: `techspawn.tips`

## What it does

- **A daily notification** at the time you choose, 09:00 by default. If the
  laptop was asleep or off then, it arrives at the first check after you
  are back, once. It waits while a window title shows you are in a meeting
  (Teams, Zoom, Google Meet, Slack huddles, screen sharing), and respects
  Do Not Disturb (Super + Ctrl + Comma).
- **Click the notification** for another tip.
- **No repeats** until you have seen every tip. Then the cycle starts again,
  never with the tip you just saw. What you have seen survives restarts.
- **Your own shortcuts:** every other tip comes from your real keybindings
  (`omarchy menu keybindings --print`), so it matches your machine, your
  own bindings included.
- **Bar widget (optional):** a lightbulb that shows the current tip, with
  Previous and Next.

## Install

```bash
omarchy plugin add https://github.com/RajShimpi/omarchy-tips
omarchy plugin enable techspawn.tips
```

To add the bar widget too:

```bash
omarchy bar put techspawn.tips
```

You can also use **Install plugin** in the Omarchy menu with the repository URL.

## Remove

```bash
omarchy plugin remove techspawn.tips
```

To clear what it left behind (the tips you have seen and your settings):

```bash
rm -f ~/.local/state/omarchy/tips.json ~/.local/state/omarchy/tips.json.lock ~/.config/omarchy/tips.json
```

## Settings

Click the pencil in the bar panel, or run `scripts/tip edit` from the plugin
folder. The first time, this creates `~/.config/omarchy/tips.json` with the
defaults and opens it in your editor. The plugin never writes that file
otherwise. Missing keys use these defaults, and changes apply within a minute:

```json
{
  "time": "09:00",
  "notify": true,
  "shortcuts": true,
  "topics": [],
  "quietWhenBusy": true
}
```

| Key | Meaning |
| --- | --- |
| `time` | When the daily tip is due, `"HH:MM"` in local time. |
| `notify` | Send the daily notification. The bar widget works either way. |
| `shortcuts` | Mix in tips made from your keybindings. |
| `topics` | Only these topics, e.g. `["Git", "Terminal"]`. Empty means all. Topics: `Omarchy`, `Screenshots`, `Notifications`, `Windows`, `Terminal`, `tmux`, `Neovim`, `Git`, `Node`, `Postgres`, `Focus`, and `Shortcut` for your keybindings. |
| `quietWhenBusy` | Hold the daily tip while you are in a meeting. |

### Keyboard

When the bar panel is open:

- `l`, Right, `j`, Down or `Enter`: next tip
- `h`, Left, `k` or Up: previous tip
- `Esc` closes the panel

## Commands

`scripts/tip` in the plugin folder:

| Command | What it does |
| --- | --- |
| `tip next` | Prints a new tip as JSON (`{"topic", "tip", ...}`) and makes it the current one. |
| `tip prev` | Prints the tip before the current one. |
| `tip current` | Prints the current tip. |
| `tip daily` | Shows today's tip if it is due. The service runs this every minute. |
| `tip notify-next` | Shows another tip as a notification. |
| `tip count` | How many tips there are and how many you have seen. |
| `tip status` | Settings, whether today's tip is due, and the current tip. |

`OMARCHY_NO_NOTIFY=1` prints the notification instead of sending it.

## How it works and dependencies

- `scripts/tip` is a Python 3 script that uses only the standard library,
  so nothing extra needs installing. It also uses `omarchy-notification-send`,
  `omarchy menu keybindings`, `omarchy-launch-editor` and `hyprctl`, which
  Omarchy already provides.
- `Service.qml` runs `scripts/tip daily` every minute. It is the only part
  that sends the daily notification. The bar widget runs once per monitor
  and only reads the state file and steps through tips.
- The written tips are in `tips.json`. Each one was checked against
  Omarchy's default keybindings, commands, shell aliases and configs.
- State: `~/.local/state/omarchy/tips.json` (`$XDG_STATE_HOME` if set)
  holds the tips you have seen, the last 50 shown, and the day the last
  daily tip went out. A file lock keeps the service and the panels from
  writing it at the same time.
- It makes no network requests and sends nothing anywhere.

## License

MIT. See [LICENSE](LICENSE).
