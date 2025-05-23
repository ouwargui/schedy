<!-- Header -->

<p align="center">
  <a href="https://schedy.io/">
    <img alt="Schedy Logo" height="128" src="Schedy/Assets.xcassets/AppIcon.appiconset/icon_128.png">
    <h1 align="center">Schedy</h1>
  </a>
</p>

<p align="center">
  <a href="https://github.com/ouwargui/schedy/actions/workflows/release-stable.yml"><img alt="Release stable workflow status" src="https://github.com/ouwargui/schedy/actions/workflows/release-stable.yml/badge.svg?branch=main"></a>
  <a href="https://github.com/ouwargui/schedy/actions/workflows/release-beta.yml"><img alt="Release beta workflow status" src="https://github.com/ouwargui/schedy/actions/workflows/release-beta.yml/badge.svg?branch=main"></a>
  <a href="https://github.com/ouwargui/schedy/blob/main/LICENSE" target="_blank"><img alt="License: GPL 3.0" src="https://img.shields.io/badge/License-GPL--3.0-success.svg?style=flat-square&color=33CC12" target="_blank" /></a>
</p>

<h6 align="center">Follow me on</h6>
<p align="center">
  <a aria-label="Follow me on X" href="https://x.com/intent/follow?screen_name=eoqguih" target="_blank"><img src="https://img.shields.io/badge/X-000000?style=for-the-badge&logo=x&logoColor=white" target="_blank" /></a>&nbsp;<a aria-label="Follow me on GitHub" href="https://github.com/ouwargui" target="_blank"><img src="https://img.shields.io/badge/GitHub-222222?style=for-the-badge&logo=github&logoColor=white" target="_blank" /></a>
</p>

## Introduction

Schedy is a menu bar app for MacOS, designed to help you manage your schedule and tasks efficiently. It provides a simple and intuitive interface for viewing your schedule at a glance. Soon you'll also be able to create, edit, delete tasks and set reminders for important events.

This repository includes the source code for Schedy's MacOS app, built using SwiftUI and a little bit of AppKit.

## Features

- **View your schedule**: Quickly see your upcoming tasks and events in a clean, easy-to-read format.

- **Multiple calendar support**: Connect to multiple calendars and view all your events in one place. Only Google Calendar is supported for now.

- **Privacy focused**: Schedy does not collect any personal data. Your accounts, schedule and tasks are stored locally on your device.

- **Keybinds**: Use keyboard shortcuts to quickly navigate through your schedule and tasks.

- **Dark mode support**: Schedy uses the native dropdown menu bar, so it automatically adapts to your system's appearance settings.

- **Create and manage tasks (soon)**: Add, edit, and delete tasks directly from the app.

- **Set reminders (soon)**: Get notified about important events and tasks.

## Installation

Go to the [latest release](https://github.com/ouwargui/schedy/releases/latest) and download the `SchedyInstaller.dmg` file. Open it and drag `Schedy.app` to your Applications folder.

## Usage

You can click on the Schedy icon in the menu bar to open the dropdown menu. From there, you can view your schedule and tasks.

### Adding your Google account

At first, you won't have any accounts connected. To add a Google account, click on the "Settings" button. This will open a new window where you can sign in to your Google account and grant Schedy access to your calendar.

### Quitting Schedy

Schedy runs in the background and will not close by pressing <kbd>Cmd</kbd> + <kbd>Q</kbd>. To quit Schedy, you need to click on the "Quit" button in the dropdown menu.

### Update Schedy

On the Schedy dropdown menu, you can find the "Check for updates" button. This will check if there are any new versions available. If there is a new version, you'll be prompted to download it.

You can also choose to let Schedy automatically check for updates. You can do this by going to the "Settings" window and enabling the "Automatically check for updates" option.

The "Receive nightly updates" option is disabled by default. You can enable it to receive beta updates, but be aware that these updates may be unstable and contain bugs. Use at your own risk.

## Shout-out

Schedy is inspired by [Amie](https://amie.so/). Thanks [@dennismuellr](https://x.com/dennismuellr) for the amazing app!

The github action for releasing is inspired on [Ghostty release workflow](https://github.com/ghostty-org/ghostty/blob/main/.github/workflows/release-tip.yml). Thanks [@mitchellh](https://github.com/mitchellh)!

The app icon is designed by my good friend [@CaiqueSobral](https://github.com/CaiqueSobral)'s girlfriend. Thanks Gi!
