# What is Chocobot?

Chocobot is an easy-to-use, easy-to-extend Bot for managing your Twitch-Chat written in ruby. While Chocobot by itself doesn't do more than connecting to a channel, plug-ins can interact with the chat. Via those plug-ins you can manage commands the bot responses to, add timed messages and many other cool tasks. Take a look at the plug-in-list below! 


## Features

At the moment Chocobot does nothing more than connecting to twitch via IRC (and logging into the chat) and providing a plug-in interface. It recognizes only two commands without any plug-ins; !ping (mods and channel owner only), that will respond with a message saying "Pong!"; and "!exit" (owner only) which will stop the bot.

### Planned Features

* Twitch-API-Connection
* Webinterface

# Plugins
## Official Plugins

* [Timer](https://github.com/Gotos/Chocobot-Timer) Create messages your bot sends after a certain time and a certain number of messages have passed
* [CustomCommands](https://github.com/Gotos/Chocobot-CustomCommands) Create new commands your bot response to on the fly

# How to run

## Quick install

Get ruby (tested with 2.0). Install data_mapper via Rubygems ('gem install data_mapper') and DataMappers adapter for the database you'd like to use, e.g. 'gem install dm-sqlite-adapter'.

## Install for non-programmers

Install Ruby. Chocobot has been tested with Version 2.0 and should work with any newer version and possibly some older ones. If you need held, you might want to take a look at [Ruby's Installationguide](https://www.ruby-lang.org/en/installation/).

Bring up a command line and enter "gem install data_mapper" - this might take some time to complete. Afterwards type "gem install dm-sqlite-adapter", if you don't want to use another database - if you don't know, what this means, don't worry, it's not important for using Chocobot. Now everything Chocobot needs is installed.

### Install for windows-users

Install Ruby from [rubyinstaller.org](http://rubyinstaller.org/downloads/). Make sure to get a Version 2.0 or higher and not the x64-version, even if you're running an x64-machine. Chocobot has been tested with Version 2.0 and should work with any newer version and possibly some older ones. If you need help, you might want to take a look at [Ruby's Installationguide](https://www.ruby-lang.org/en/installation/). You should make sure to check "Add Ruby executables to your PATH" and "Associate .rb and .rbw-files with ruby".

Next, you need to download SQLite. Go to [the SQLite website](https://www.sqlite.org/download.html) and download the zip-file with dlls for Windows (win32). Extract the files in the zip to C:\Windows\system32.
Now, open up a command line. It might be called command line for ruby, if you are using Windows 8. Type "gem install sqlite3". This will take some time. Afterwards type "gem install data_mapper" and thereafter "gem install dm-sqlite-adapter". Now everything Chocobot needs is installed.

## Configure Chocobot

First copy the file "config-sample.yaml" and name the copy "config.yaml". You'll need to edit only a few lines. First, edit the username. You should enter the username the bot should use to connect to your chat. Also please edit the channel. It needs to be the username of the channel Chocobot should moderate, starting with a hash (#). E.g. if Chocobot should connect to grufty's Chat, put "#grufty" here.

Now you need to edit your OAuth-Token. Go to [Twitch's Chat OAuth Generator](http://www.twitchapps.com/tmi/) to get the token and place it into the configfile. Remember not to override the "oauth:"-bit, it is important.
Next you need to select your database. If you want to stay with sqlite, first create a new, empty file which will be the database. You can call it what you like, chocobot.sqlite might be a good idea. Now, enter "sqlite://[PATH_TO_DATABASE]" as a database connection, where PATH_TO_DATABASE is the absolute path to the file you just entered. For unix-users this might be something like "sqlite:///home/username/chocobot/chobobot.sqlite", for windows-users it might be "sqlite://C:/chocobot/chocobot.sqlite" (mind the forward-slashes!).

That should be all. If you know what you are doing you can set a different server/port or you can change the logging, but you don't need to.

## Installing Plugins

Plugins go into the "Plugins"-Folder. They need to be in a subfolder named the same as the main pluginfile - don't worry, Plugins will usually provide that folder or at least tell you how it should be named.

## Running Chocobot

Just start Chocobot.rb. To stop it, either send the command "!exit" as the channelowner, or press Ctrl+C.

# Downloads

You can download bundled releases of Chocobot on the [releasepage](https://github.com/Gotos/Chocobot/releases).
