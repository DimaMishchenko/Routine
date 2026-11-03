# Routine

A native habit tracker for iPhone, iPad and Mac, with daily, weekly and monthly goals.

[![CI](https://github.com/DimaMishchenko/Routine/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/DimaMishchenko/Routine/actions/workflows/ci.yml)
[![MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![Maintenance mode](https://img.shields.io/badge/status-maintenance%20mode-yellow)](CONTRIBUTING.md)
![iOS 26+](https://img.shields.io/badge/iOS-26%2B-blue)
![macOS 26+](https://img.shields.io/badge/macOS-26%2B-blue)

[Website](https://routine.dimasike.com) · [Support](https://routine.dimasike.com/support.html) · [Privacy](https://routine.dimasike.com/privacy.html)

![Routine on a MacBook, iPad and iPhone, showing example habits and progress](Website/public/assets/routine-devices.webp)

- 🎯 Daily, weekly or monthly goals.
- 📈 Progress history, calendars and charts.
- 🔔 Local reminders on your schedule.
- ☁️ Store data locally or use supported iCloud sync.
- 🔐 Face ID, Touch ID or passcode protection.
- 💙 Free and open source, with unlimited routines and no ads or analytics.

> The free 1.1.0 update is not released yet. Routine is currently unavailable on the App Store.

## Our story 👋

We started building Routine in June 2021 to make building habits feel simple.
We published it on the App Store, but life got busy and we couldn’t give it the time it deserved.

Now we’re bringing Routine back, completely free. Every feature is included, with no subscriptions or purchases. 🌱

[@dimasike_](https://x.com/dimasike_) · [@mikemikovich24](https://x.com/mikemikovich24)

## Development

Routine is in maintenance mode, focused on fixes, compatibility and security.

Install Xcode 27.1, [mise](https://mise.jdx.dev/) and [xcbeautify](https://github.com/cpisciotta/xcbeautify):

```sh
mise install
mise exec -- make build
open Routine.xcworkspace
```

Choose **RoutineApp Local** and an iOS 26+ simulator. No Apple account is required.
See [Contributing](CONTRIBUTING.md) for cloud builds and contribution guidelines, or [report a bug](https://github.com/DimaMishchenko/Routine/issues).

[Architecture](ARCHITECTURE.md) · [Testing](TESTING.md) · [Security](SECURITY.md) · [MIT license](LICENSE)
