# Devbar

A macOS menu bar app providing quick access to 60+ developer tools (encoders, formatters, converters, generators, and more).

## Requirements

- macOS 13.0+ (Ventura or later)
- Xcode 15.0+

## Build & Install

### 1. Clone the repo

```bash
git clone <repo-url>
cd devbar
```

### 2. Open in Xcode

```bash
open devbar.xcodeproj
```

### 3. Select the scheme and destination

In Xcode, make sure the `devbar` scheme is selected and the destination is set to **My Mac**.

### 4. Build and run

Press `Cmd+R` or go to **Product > Run**.

The app will launch and a wrench icon will appear in your menu bar. Click it to open the tools panel.

### 5. (Optional) Install as a persistent app

To keep the app running after closing Xcode:

1. In Xcode, go to **Product > Archive**.
2. Once the archive is built, click **Distribute App > Copy App**.
3. Move the exported `devbar.app` to `/Applications`.
4. Launch it from `/Applications/devbar.app`.
5. To start it automatically on login, go to **System Settings > General > Login Items** and add `devbar.app`.

## Redeploying After Changes

### During development (Xcode)

1. Make your code changes.
2. Press `Cmd+R` to rebuild and relaunch.
3. If the app is already running in the menu bar, Xcode will terminate the old instance and start the new one automatically.

### For a production build

1. Make your code changes.
2. In Xcode, bump the version/build number in the project target settings (optional but recommended).
3. Go to **Product > Archive**.
4. Distribute and copy the new `devbar.app`.
5. Quit the running instance from the menu bar (or via `killall devbar` in Terminal).
6. Replace `/Applications/devbar.app` with the new build.
7. Relaunch the app.

```bash
# Quick replace via Terminal
killall devbar 2>/dev/null; cp -R /path/to/exported/devbar.app /Applications/devbar.app && open /Applications/devbar.app
```
