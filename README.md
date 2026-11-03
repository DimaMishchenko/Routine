# Routine

A native habit tracker for iPhone, iPad and Mac, with daily, weekly and monthly goals.

[![CI](https://github.com/DimaMishchenko/Routine/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/DimaMishchenko/Routine/actions/workflows/ci.yml)
[![MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![Maintenance mode](https://img.shields.io/badge/status-maintenance%20mode-yellow)](CONTRIBUTING.md)
![iOS 26+](https://img.shields.io/badge/iOS-26%2B-blue)
![macOS 26+](https://img.shields.io/badge/macOS-26%2B-blue)

[Website](https://routine.dimasike.com) · [Support](https://routine.dimasike.com/support.html) · [Privacy policy](https://routine.dimasike.com/privacy.html) · [Report a bug](https://github.com/DimaMishchenko/Routine/issues)

**Fully free. Unlimited routines. No purchases, subscriptions, analytics or app account.**

> The free 1.1.0 update has not shipped yet. Routine is currently unavailable on the
> App Store; existing 1.0.4 installations may have different features and privacy behavior.

![Routine on a MacBook, iPad and iPhone, showing example habits and progress](Website/public/assets/routine-devices.webp)

- 🎯 Daily, weekly or monthly goals.
- 📈 Progress history, calendars and charts.
- 🔔 Local reminders on your schedule.
- ☁️ Store data locally or use supported iCloud sync.
- 🔐 Face ID, Touch ID or passcode protection.
- 💙 Free and open source, with unlimited routines and no ads or analytics.

**Maintenance mode:** fixes, platform compatibility and security take priority.
Major new features are not planned; support and review have no guaranteed schedule.

## Run locally

Install Xcode 27.1, [mise](https://mise.jdx.dev/) and [xcbeautify](https://github.com/cpisciotta/xcbeautify):

```sh
mise install
mise exec -- make build
open Routine.xcworkspace
```

Choose **RoutineApp Local** and an iOS 26+ simulator. No Apple account is required.
See [Contributing](CONTRIBUTING.md) for cloud builds and [Testing](TESTING.md) for verification.

[Architecture](ARCHITECTURE.md) · [Privacy](PRIVACY.md) · [Security reports](SECURITY.md) · [MIT license](LICENSE) · [Third-party notices](THIRD_PARTY_NOTICES.md)
