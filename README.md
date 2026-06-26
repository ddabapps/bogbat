# bogbat

A bog-basic template replacement program.

## Download & Installation

Download the latest version from the project's GitHub [Releases page](https://github.com/ddabapps/bogbat/releases).

Extract `BogBat.exe` from the downloaded zip file. Copy `BogBat.exe` anywhere on your computer and run.

_BogBat_ is currently only available as a 64 bit Windows build.

## Compiling

* Download a version of `BogBat.exe` from https://github.com/ddabapps/bogbat/releases. Yes, BogBat is required to help build itself. Very recursive!

* Clone or download the source code from https://github.com/ddabapps/bogbat.

* Open Delphi (13.1 or later).

* Open Delphi's _Options_ dialogue box (_Tools | Options_). Select the _IDE | Environment Variables_ section and add the `BogBatRoot` environment variable under _User System Overrides_ and set its value to the path of the directory containing `BogBat.exe`, without trailing backslash.

* Load `src/BogBat.dpr` into the IDE. 

* Build.

Note that the IDE uses the BogBat executable to create the version information resource source file from `src/VersionInfo.rc.template`.

## License

MIT License, copyright 2025-2026 (c) Peter Johnson.
