import psutil
import discord
import os
import datetime
import aiosqlite

from difflib import get_close_matches
from ast import literal_eval
from typing import List, Union, Dict
from dotenv import load_dotenv
from discord.ext import tasks
from discord import Option

client = discord.Bot()
load_dotenv()
TOKEN = os.getenv('TOKEN')
CHANNELID = os.getenv('ChannelID')
GUILDID = os.getenv('GuildID')
LOGFILE = f'{os.getenv("APPDATA")}\\Cherax\\Cherax.log'
LINES = []

@client.event
async def on_ready() -> None:
    print(f'Logged in as {client.user.name}#{client.user.discriminator}.')
    if not handleLog.is_running():
        handleLog.start()

async def checkDatabase() -> None:
    async with aiosqlite.connect('players.db') as db:
        await db.execute('create table if not exists Players(RID INTEGER, Username TEXT, IP TEXT)')

async def handleDatabase(rid: int, name: str, ip: str) -> None:
    await checkDatabase()
    async with aiosqlite.connect('players.db') as db:
        async with db.execute(f'select Username, IP from Players where RID="{rid}"') as cursor:
            result = await cursor.fetchone()
        if not result:
            db_name = [name]
            db_ip = [ip]
            await db.execute(f'insert into Players(RID, Username, IP) values(?,?,?)',
                            (rid, str(db_name), str(db_ip)))
            await db.commit()
        else:
            db_name, db_ip = result
            db_name = literal_eval(db_name)
            db_ip = literal_eval(db_ip)
            if name not in db_name:
                db_name.append(name)
                await db.execute(f'update Players set Username="{str(db_name)}" where RID="{rid}"')
                await db.commit()
            if ip not in db_ip:
                db_ip.append(ip)
                await db.execute(f'update Players set Username="{str(db_ip)}" where RID="{rid}"')
                await db.commit()

@tasks.loop(seconds=0.1)
async def handleLog() -> None:
    with open(LOGFILE, 'r', encoding='utf8') as f:
        for line in f:
            if line.strip() not in LINES:
                strippedline = line.strip().split(' ', 2)[2]
                events = strippedline.split(' ', 1)
                if events[0] == '[Chat|All]':
                    LINES.append(line.strip())
                    name, msg = events[1].split(' wrote: ', 1)
                    if not msg.startswith('[Discord] '):
                        channel = client.get_channel(int(CHANNELID))
                        if len(await channel.webhooks()) == 0:
                            webhook = await channel.create_webhook(name='GTA Online')
                        else:
                            webhook = (await channel.webhooks())[0]
                        await webhook.send(msg, username=name, avatar_url=client.user.display_avatar.url)
                else:
                    LINES.append(line.strip())
                    events = strippedline.split(' ', 2)
                    if events[0] == '[Session]' and events[1] == 'Player':
                        name = events[2].split(' (', 1)[0]
                        rid = events[2].split(' (', 1)[1].split(') - ', 1)[0]
                        ip = events[2].split(' (', 1)[1].split(') - ', 1)[1].split(' - ', 1)[0]
                        await handleDatabase(int(rid), name, ip)

async def getSessionInfo() -> Union[Dict, bool]:
    players = {}
    nomgrcount = 0
    leftcount = 0
    count = 0
    nomgr = None
    if 'GTA5.exe' not in (p.name() for p in psutil.process_iter()):
        return False
    with open(LOGFILE, 'r', encoding='utf8') as f:
        for line in f:
            nomgrcount += 1
            if line.strip().split(' ', 2)[2] == '[Hooking] NOMGR hooked':
                nomgr = nomgrcount
    if not nomgr:
        return False
    with open(LOGFILE, 'r', encoding='utf8') as f:
        for line in f:
            leftcount += 1
            if leftcount < nomgr:
                continue
            elif line.strip().split(' ', 2)[2] == '[Info] Left session':
                return False
    with open(LOGFILE, 'r', encoding='utf8') as f:
        for line in f:
            count += 1
            if count < nomgr:
                continue
            else:
                line = line.strip().split(' ', 2)[2]
                events = line.split(' ', 2)
                if events[0] == '[Session]' and events[1] == 'Player':
                    name = events[2].split(' (', 1)[0]
                    rid = events[2].split(' (', 1)[1].split(') - ', 1)[0]
                    ip = events[2].split(' (', 1)[1].split(') - ', 1)[1].split(' - ', 1)[0]
                    event = events[2].split(' (', 1)[1].split(') - ', 1)[1].split(' - ', 1)[1]
                    if event == 'has joined your session':
                        players[rid] = (name, ip)
                    elif event == 'has left your session':
                        try:
                            del players[rid]
                        except:
                            pass
    return players

@client.event
async def on_message(message: discord.Message) -> None:
    if message.channel.id == int(CHANNELID) and message.author.id != client.user.id and not message.webhook_id:
        if len(message.content) > 0:
            if len(message.content) > 120:
                message.content = f'{message.content[:120]}...'
            msg = f'{datetime.datetime.now().strftime("[%Y-%#m-%#d %H:%M:%S]")} [Chat|Discord] {message.author.display_name} wrote: {message.content}\n'
            with open(LOGFILE, 'a', encoding='utf8') as f:
                f.write(msg)

async def getCloseMatches(username: str) -> List[str]:
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
    await checkDatabase()
    async with aiosqlite.connect('players.db') as db:
        async with db.execute(f'select RID, Username, IP from Players where Username like "%\'{username}\'%"') as cursor:
            result = await cursor.fetchone()
        if not result:
            close_matches = await getCloseMatches(username)
            embed = discord.Embed(
                title=':x: User not found.',
                color=discord.Color.embed_background(),
                timestamp=discord.utils.utcnow()
            )
            embed.set_footer(
                text='\u200b',
                icon_url=client.user.display_avatar.url
            )
            if len(close_matches) > 0:
                embed.description = f'Perhaps you meant:\n\n- ' + '\n- '.join(close_matches)
            await ctx.respond(embed = embed, ephemeral=True)
        else:
            rid, name, ip = result
            ip = f'- ' + '\n'.join(literal_eval(ip))
            name = f'- ' + '\n'.join(literal_eval(name))
            embed = discord.Embed(
                title='User information.',
                color=discord.Color.embed_background(),
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
                name='Known usernames',
                value=username
            )
            embed.add_field(
                name='Known IP addresses',
                value=ip
            )
            embed.add_field(
                name='Rockstar ID',
                value=rid,
                inline=False
            )
            await ctx.respond(embed = embed)

@client.slash_command(guild_ids=[int(GUILDID)])
async def session(ctx: discord.ApplicationContext) -> None:
    '''Display information about the current session.'''
    players = await getSessionInfo()
    if players == False:
        embed = discord.Embed(
            title=':x: No active session.',
            color=discord.Color.embed_background(),
            timestamp=discord.utils.utcnow()
        )
        embed.set_footer(
            text='\u200b',
            icon_url=client.user.display_avatar.url
        )
        await ctx.respond(embed = embed, ephemeral=True)
    elif len(players.keys()) == 0:
        embed = discord.Embed(
            title=':x: No players in session.',
            color=discord.Color.embed_background(),
            timestamp=discord.utils.utcnow()
        )
        embed.set_footer(
            text='\u200b',
            icon_url=client.user.display_avatar.url
        )
        await ctx.respond(embed = embed, ephemeral=True)
    else:
        count = 1
        names = []
        rids = []
        ips = []
        for rid in players.keys():
            name, ip = players[rid]
            names.append(f'{count}. {name}')
            rids.append(rid)
            ips.append(ip)
            count += 1
        embed = discord.Embed(
            title='Session information.',
            color=discord.Color.embed_background(),
            timestamp=discord.utils.utcnow()
        )
        embed.set_footer(
            text='\u200b',
            icon_url=client.user.display_avatar.url
        )
        embed.add_field(
            name='Name',
            value='\n'.join(names)
        )
        embed.add_field(
            name='RID',
            value='\n'.join(rids)
        )
        embed.add_field(
            name='IP',
            value='\n'.join(ips)
        )
        await ctx.respond(embed = embed)

with open(LOGFILE, 'r', encoding='utf8') as f:
    for line in f:
        LINES.append(line.strip())
           
client.run(TOKEN)