# GTACord V1

## Description

GTACord provides a bridge between Discord and GTA Online. It allows you to send and receive messages in the GTA Online chat through Discord and it stores information (IP/RID) about all players in a database.

## Setup

Make sure you have Python 3.6 or higher installed, then create a bot at the [Discord Developer Portal.](https://discord.com/developers/applications)

The bot requires the following scopes:
- bot
- application.commands

And the following permissions:
- Manage webhooks
- Read messages/view channels
- Send messages
- Read message history

Invite the bot to your server and copy the token as we will need it later.

Place GTACord.lua in %appdata%\Cherax\Lua and place bot.py and requirements.txt anywhere you want but in the same folder. Open a terminal in this folder and run:
```
python -m pip install -r requirements.txt
```
You can now delete requirements.txt as we don't need it anymore.

Create a new file '.env' (without anything in front) in the same folder as bot.py and add these lines to it:
```
TOKEN=''
ChannelID=''
GuildID=''
```
Paste in your token, the channel ID where you want to link the GTA chat and the guild ID.

Load the lua in GTA Online and start the bot with:
```
python bot.py
```

## Options (Discord)

- /get \<username>
