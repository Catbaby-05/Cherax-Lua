import discord
import os
import datetime
import aiosqlite

from difflib import get_close_matches
from ast import literal_eval
from typing import List, Tuple
from dotenv import load_dotenv
from discord.ext import tasks
from discord import Option

client = discord.Bot()
load_dotenv()
TOKEN = os.getenv('TOKEN')
CHANNELID = os.getenv('ChannelID')
GUILDID = os.getenv('GuildID')
LOGFILE = f'{os.getenv("APPDATA")}\\Cherax\\Cherax.log'
channel = None
lastline = None
lastsend = None
playerpos = 0
lastplayer = None
banned = None

@client.event
async def on_ready() -> None:
    global channel
    channel = client.get_channel(int(CHANNELID))
    if not get_message.is_running():
        get_message.start()
    if not get_players.is_running():
        get_players.start()

async def check_db() -> None:
    async with aiosqlite.connect('players.db') as db:
        await db.execute('create table if not exists Players(RID INTEGER, Username TEXT, IP TEXT)')

async def handle(rid: int, username: str, ip: str) -> None:
    await check_db()
    async with aiosqlite.connect('players.db') as db:
        async with db.execute(f'select Username, IP from Players where RID="{rid}"') as cursor:
            result = await cursor.fetchone()
        if not result:
            username = [username]
            ip = [ip]
            await db.execute(f'insert into Players(RID, Username, IP) values(?,?,?)',
                            (rid, str(username), str(ip)))
            await db.commit()
        else:
            db_username, db_ip = result
            db_username = literal_eval(db_username)
            db_ip = literal_eval(db_ip)
            if username not in db_username:
                db_username.append(username)
                await db.execute(f'update Players set Username="{str(db_username)}" where RID="{rid}"')
                await db.commit()
            if ip not in db_ip:
                db_ip.append(ip)
                await db.execute(f'update Players set IP="{str(db_ip)}" where RID="{rid}"')
                await db.commit()

async def getlines() -> List[str]:
    with open(LOGFILE, 'r', encoding='utf8') as f:
        return [line.strip() for line in f]

async def getchat(line: str) -> Tuple[str, str]:
    try:
        line = line.split(' ', 2)[2]
        event = line.split(' ', 1)
        if event[0] != '[Chat|All]':
            return False
        return event[1].split(' wrote: ', 1)
    except:
        return False

async def getplayer(line: str) -> Tuple[int, str, str]:
    try:
        line = line.split(' ', 2)[2]
        event = line.split(' ', 2)
        if event[0] == '[Session]' and event[1] == 'Player':
            eventsplit = event[2].split(' (', 1)
            username = eventsplit[0]
            eventsplit = eventsplit[1].split(') - ')
            rid = eventsplit[0]
            ip = eventsplit[1].split(' - ')[0]
            return rid, username, ip
        else:
            return False
    except:
        raise

@tasks.loop(seconds=0.5)
async def get_message() -> None:
    global channel, lastline, lastsend
    last_line = (await getlines())[-1]
    if last_line == lastline:
        return
    else:
        lastline = last_line
    if lastline == lastsend:
        return
    else:
        lastchat = await getchat(last_line)
        if not lastchat:
            return
        else:
            author, message = lastchat
            if len(await channel.webhooks()) == 0:
                webhook = await channel.create_webhook(name='GTA Online')
            else:
                webhook = (await channel.webhooks())[0]
            if message != banned:
                await webhook.send(message, username=author, avatar_url=client.user.display_avatar.url)
                lastsend = last_line

@tasks.loop(seconds=0.5)
async def get_players():
    global playerpos, lastplayer
    if playerpos == 0:
        lines = await getlines()
        for line in lines:
            player = await getplayer(line)
            if not player:
                continue
            else:
                rid, username, ip = player
                await handle(rid, username, ip)
        playerpos = len(lines)
    else:
        last_line = (await getlines())[-1]
        if last_line == lastplayer:
            return
        else:
            lastplayer = last_line
            playerpos += 1
            player = await getplayer(last_line)
            if not player:
                return
            else:
                rid, username, ip = player
                await handle(rid, username, ip)

@client.event
async def on_message(message: discord.Message) -> None:
    global banned
    if message.channel.id == int(CHANNELID) and message.author.id != client.user.id and not message.webhook_id:
        if len(message.content) > 0:
            if len(message.content) > 120:
                message.content = f'{message.content[:120]}...'
            msg = f'{datetime.datetime.now().strftime("[%Y-%#m-%#d %H:%M:%S]")} [Chat|Discord] {message.author.display_name} wrote: {message.content}'
            with open(LOGFILE, 'a', encoding='utf8') as f:
                f.write(f'\n{datetime.datetime.now().strftime("[%Y-%#m-%#d %H:%M:%S]")} [Chat|Discord] {message.author.display_name} wrote: {message.content}')
            banned = f'Discord: {message.author.display_name}: {message.content}'

async def get_matching(username: str) -> List[str]:
    await check_db()
    async with aiosqlite.connect('players.db') as db:
        async with db.execute(f'select Username from Players') as cursor:
            usernames_db = await cursor.fetchall()
    usernames = []
    for username_db in usernames_db:
        for name in literal_eval(username_db[0]):
            usernames.append(name)
    return get_close_matches(username, usernames, n=10, cutoff=0.6)

@client.slash_command(guild_ids=[int(GUILDID)])
async def get(ctx: discord.ApplicationContext, username: Option(str, 'The GTA Online username.')) -> None:
    '''Get information about a GTA Online player by username.'''
    await check_db()
    async with aiosqlite.connect('players.db') as db:
        async with db.execute(f'select RID, Username, IP from Players where Username like "%\'{username}\'%"') as cursor:
            result = await cursor.fetchone()
        if not result:
            close_matches = await get_matching(username)
            embed = discord.Embed(
                title=':x: User not found.',
                timestamp=discord.utils.utcnow()
            )
            embed.set_footer(
                text='\u200b',
                icon_url=client.user.display_avatar.url
            )
            if len(close_matches) > 0:
                matches = '\n- '.join(close_matches)
                matches = f'- {matches}'
                embed.description = f'Perhaps you meant:\n\n{matches}'
            await ctx.respond(embed = embed)
        else:
            rid, username, ip = result
            ip = '\n- '.join(literal_eval(ip))
            ip = f'- {ip}'
            username = '\n- '.join(literal_eval(username))
            username = f'- {username}'
            embed = discord.Embed(
                title='User Information.',
                timestamp=discord.utils.utcnow()
            )
            embed.set_thumbnail(
                url=client.user.display_avatar.url
            )
            embed.set_footer(
                text='\u200b',
                icon_url=client.user.display_avatar.url
            )
            embed.add_field(
                name='Known Usernames',
                value=username
            )
            embed.add_field(
                name='Known IP Addresses',
                value=ip
            )
            embed.add_field(
                name='Rockstar ID',
                value=rid,
                inline=False
            )
            await ctx.respond(embed = embed)
           
client.run(TOKEN)