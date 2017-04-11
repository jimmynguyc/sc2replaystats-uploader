# sc2replaystats-uploader

## Installation

First, install Ruby using [rbenv](http://rbenv.org/) or [rvm](http://rvm.io/). Then run

```
$ bundle install
```

## Configuration

Create an empty file `.dotenv` and edit the content with the following details

```
BLIZZARD_ACCOUNT_FOLDER="path-to-blizzard-account-folder"   (e.g. Blizzard/StarCraft II/Accounts/12345678)
ACCOUNTS="comma-separated-account-profiles"   (e.g. 1-S2-1-1234567,3-S2-1-1234567,6-S2-1-1234567)
GAME_TYPES="Multiplayer,Campaign,Challenge"
USERNAME="sc2replaystats-username"
PASSWORD="sc2replaystsats-password"
```

## Run it

```
./bin/upload
```
