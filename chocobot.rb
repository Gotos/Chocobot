#!/usr/bin/env ruby
require 'socket'

# Config
host = 'irc.twitch.tv'
port = 6667
oauth = 'oauth:93ppl5bfy07ujkswfmrj4fpjgl8rufl'
username = 'gRuFtBoT'
channel = '#gruftbot'

class Chocobot

	def initialize(host, port, username, oauth, channel)
		# Initialize
		@irc = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
		@irc.connect(Socket.pack_sockaddr_in(port, host))
		@irc.puts("PASS " + oauth)
		@irc.puts("NICK " + username)
		@channel = channel
		@irc.write("JOIN " + @channel + "\n")
		@run = true
		puts "Initialization complete!"
	end

	def message(msg)
		@irc.puts("PRIVMSG " + @channel + " :" + msg)
	end

	def ping()
		@irc.puts("PONG :Pong")
	end

	def commands(nick, channel, msg)
		case msg.split()[0]
		when "!exit"
			puts "Exiting..."
			@run = false
		end
	end

	def main()
		# Main-Loop
		message("Selftest complete.")
		while @run
			data = @irc.gets()
			if data != nil
				data.strip!()
				puts data
				if data.index("PING :") != nil
					ping()
				end
				if data.index(' MODE ') != nil
					pass #TODO
				end
				if data.index(' PRIVMSG ')!= nil
					nick = ""
					#nick = data.split('!')[0][1:]
					channel = data.split(' PRIVMSG ')[1].split(' :')[0]
					msg = data.split(' PRIVMSG ')[1].split(' :')[1]
					puts "Msg: " + msg
					if msg[0] == "!"
						commands(nick, channel, msg)
					end
				end
			end
		end
		@irc.puts("PART " + @channel)
		@irc.close()
	end
end

bot = Chocobot.new(host, port, username, oauth, channel)
bot.main()