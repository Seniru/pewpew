import aiotfm
import asyncio
import json
import os
import re

from discord_webhook import DiscordWebhook

WEBHOOK_URL = "https://discord.com/api/webhooks/818491176587624488/{}".format(os.getenv("LEADERBOARD_WEBHOOK_ID"))

def pad_text(text, max_width):
	return text + (" " * (max_width - len(text)))

class Bot(aiotfm.Client):

	def __init__(self, community=0):
		super().__init__(community, bot_role=True)
		self.pid = 0
		self.message_buffer = ""

	async def handle_packet(self, conn, packet):
		handled = await super().handle_packet(conn, packet.copy())

		if not handled:  # Add compatibility to more packets
			CCC = packet.readCode()

			if CCC == (60, 4):  # Tribulle V2 enabled
				print(f'Tribulle 2 : {packet.readBool()}')
			elif CCC == (6, 9):
				message = packet.readUTF()
				if message[0:2] == "\r\n":
					self.message_buffer += message[2:]
				elif message == "\x1a":
					self.dispatch("buffered_message", self.message_buffer)
					self.message_buffer = ""


	def run(self, block=True):
		self.loop.run_until_complete(self.start())
		if block:
			self.loop.run_forever()

	async def on_login_ready(self, online_players, community, country):
		print('Connected to Transformice.')
		print(f'There are {online_players} online players.')
		print(f'Received {community}-{country} as community.')
		await self.login("Mapa_bot#9725", os.getenv("PASSWORD"), False, room="*#castle@Mapa_bot#9725")

	async def on_logged(self, player_id, username, played_time, community, pid):
		self.pid = pid

	async def on_ready(self):
		print('Connected to the community platform.')
		await self.sendRoomMessage("!leaderboard pewpew")
		buffered_leaderboard = await self.wait_for("on_buffered_message")
		res = "** **         :trophy:      **Pewpew leaderboard**     :trophy: \n\n"
		i = 1
		for leaders in buffered_leaderboard.split("|"):
			data = leaders.split(",")
			name, rounds, survives, wins, commu = data[0], int(data[1]), int(data[2]), int(data[3]), data[4]

			name_tag = re.match("(.+)(#\d+)", name).groups()
			

			res += "{medal}{flag}  **{name} **\n     ┗`(`     :trophy: {wins} :heart: {survives} :skull: {deaths} `)` `/` {rounds}\n".format(
				medal = ":first_place:" if i == 1 else (":second_place:" if i == 2 else (":third_place:" if i == 3 else ":medal:")),
				flag = ":flag_" + ("gb" if commu in ["en", "e2", "xx", "int"] else commu) + ":",
				name = name_tag[0] + "`" + name_tag[1] + "`",
				wins = str(wins).ljust(5),
				survives = str(survives).ljust(5),
				deaths = str(rounds - survives).ljust(5),
				rounds = rounds
			)

			if i == 5:
				DiscordWebhook(url=WEBHOOK_URL, content = res).execute()
				import sys
				sys.exit(0)

			i += 1

	async def on_joined_room(self, room):
		self.room = room.decode() if isinstance(room, bytes) else room
		print(f'Joined room [{self.room}]')
		

bot = Bot()
bot.run()
