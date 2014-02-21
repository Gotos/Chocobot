#!/usr/bin/env ruby
require 'socket'
require './settings.rb'
#require './logger.rb'

class Chocobot

	# Initialize
	def initialize()

		# Connect
		concon = Settings.connection
		@irc = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
		@irc.connect(Socket.pack_sockaddr_in(concon[:port], concon[:host]))
		@irc.puts("PASS " + concon[:oauth])
		@irc.puts("NICK " + concon[:username])
		@channel = concon[:channel]
		@irc.write("JOIN " + @channel + "\n")
		@run = true

		#@logger = Logger.new()

		puts "Initialization complete!"
	end

	# Sends a Message to current channel
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

	# Main-Loop
	def main()
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
					#TODO
				end
				if data.index(' PRIVMSG ') != nil
					nick = ""
					#nick = data.split('!')[0][1:]
					channel = data.split(' PRIVMSG ')[1].split(' :')[0]
					msg = data.split(' PRIVMSG ')[1].split(' :')[1]
					puts "Msg: " + msg
					if msg[0] == "!"
						commands(nick, channel, msg)
					end
				end
				#if data.index(@channel + ' :') != nil && @logger.joins

				#end
			end
		end
		@irc.puts("PART " + @channel)
		@irc.close()
	end
end


# Start everything
Settings.load!("config.yaml")
bot = Chocobot.new()
bot.main()