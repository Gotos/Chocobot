#!/usr/bin/env ruby
require 'socket'
require './settings.rb'
require './logger.rb'

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

		@logger = Logger.new()

		@logger.puts("Initialization complete!", true)
		trap("INT") {
			@run = false
			@irc.puts("PART " + @channel)
			@logger.close()
			@irc.close()
		}
	end

	# Sends a Message to current channel
	def message(msg)
		@irc.puts("PRIVMSG " + @channel + " :" + msg)
		@logger.puts(Settings.connection[:username] + ": " + msg)
	end

	def ping()
		@irc.puts("PONG :Pong")
	end

	def commands(nick, channel, msg)
		case msg.split()[0]
		when "!exit"
			@logger.puts("Exiting...", true)
			@run = false
		end
	end

	# Main-Loop
	def main()
		message("Selftest complete.")
		
		while @run
			# ctrl-c catching
			begin
				data = @irc.gets()
			rescue IOError => e
				if !@irc.closed?()
					raise e
				end
				return
			end

			if data != nil
				data.strip!()
				#puts data
				case(data.split(" ", 3)[1])
				when "PING"
					ping()
				when "MODE"
					#todo
				when "PRIVMSG"
					nick = data.split('!', 2)[0][1..-1]
					channel = data.split(' ', 3)[2].split(' :', 2)[0]
					msg = data.split(' ', 3)[2].split(' :', 2)[1]
					@logger.puts(nick + ": " + msg, @logger.messages())
					if msg[0] == "!"
						commands(nick, channel, msg)
					end
				when "353"
					@logger.puts("Users: " + data.split(@channel + ' :', 2)[1], @logger.joins())
				end
			end
		end

		@irc.puts("PART " + @channel)
		@logger.close()
		@irc.close()
	end
end


# Start everything
Settings.load!("config.yaml")
bot = Chocobot.new()
bot.main()