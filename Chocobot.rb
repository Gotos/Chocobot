#!/usr/bin/env ruby
require 'socket'
require 'set'
require './Settings.rb'
require './Logger.rb'
require './Messager.rb'
require './PluginLoader.rb'
require 'rubygems'
require 'data_mapper'

class Chocobot

	# Initialize
	def initialize()

		concon = Settings.connection
		@logger = Logger.new()

		# Database connection
		DataMapper.setup(:default, Settings.database[:connection])

		PluginLoader.load()

		DataMapper.auto_upgrade!
		DataMapper.finalize

		# Connect
		@username = concon[:username].downcase
		@channel = concon[:channel].downcase
		@messager = Messager.new(concon[:host], concon[:port], concon[:oauth], @username, @channel, @logger, self)
		PluginLoader.boot(@messager, @logger)
		@run = true

		@logger.puts("Initialization complete!", true)
		trap("INT") {
			@run = false
			@messager.stop()
			@logger.close()
		}
	end

	# Sends a Message to current channel
	def message(msg)
		@messager.message(msg)
	end

	def initOps()
		@ops = Set.new([@username])
		@subs = Set.new()
	end

	def ping(text)
		@messager.ping()
		@messager.raw("PONG " + text)
	end

	def commands(nick, msg)
		if nick == @channel[1..-1]
			priv = 0
		elsif @ops.include?(nick)
			priv = 10
		elsif @subs.include?(nick)
			priv = 20
		else
			priv = 30
		end
		data = msg.split(' ')
		cmd = data[0]
		cmdExecuted = false

		for command in PluginLoader.preCommands.values
			if cmd == command.cmd
				if command.run(data[1..-1], priv, nick)
					cmdExecuted = true
					break
				end
			end
		end

		if !cmdExecuted
			cmdExecuted = true
			case data[0]
			when "!exit"
				if priv <=10
					@logger.puts("Exiting...", true)
					@run = false
				end
			when "!ping"
				message("Pong!")
			else
				cmdExecuted = false
			end
		end

		if !cmdExecuted
			for command in PluginLoader.postCommands.values
				if cmd == command.cmd
					if command.run(data[1..-1], priv, nick)
					break
				end
				end
			end
		end

	end

	# Main-Loop
	def main()
		#message("Selftest complete.")
		#@timer.add("test", "Hallo!", 5, 1)
		
		while @run
			# ctrl-c catching
			begin
				data = @messager.gets()
			rescue IOError => e
				if !@messager.closed?()
					raise e
				end
				return
			end

			if data != nil
				data.strip!()
				#puts data
				baseTriple = data.split(' ',3)
				if baseTriple[0] == "PING"
					ping(data.split(' ',2)[1])
				end
				case(baseTriple[1])
				when "MODE"
					meta = baseTriple[2].split(' ', 3)
					channel = meta[0]
					nick = meta[2]
					if channel.downcase == @channel
						if meta[1] == "+o"
							@ops.add(nick)
							@logger.puts("OP: " + nick, @logger.op())
						elsif meta[1] == "-o"
							@ops.delete(nick)
							@logger.puts("DEOP: " + nick, @logger.op())
						end
					end
				when "PRIVMSG"
					nick = baseTriple[0].split('!', 2)[0][1..-1]
					meta = baseTriple[2].split(' :', 2)
					channel = meta[0]
					msg = meta[1]
					if channel.downcase == @channel
						PluginLoader.newMsg(msg)
						if @subs.include?(nick)
							@logger.puts("SUB " + nick + ": " + msg, @logger.messages())
						else
							@logger.puts(nick + ": " + msg, @logger.messages())
						end
						if msg[0] == "!"
							commands(nick, msg)
						end
						@subs.delete(nick)
					elsif channel.downcase == @username
						if nick == "jtv"
							info = msg.split(" ")
							case(info[0])
							when "SPECIALUSER"
								if info[2] == "subscriber"
									@subs.add(info[1])
								end
							end
						else
							@logger.puts("PRIV: " + nick + ": " + msg, @logger.messages())
						end
					end
				when "353"
					channel = baseTriple[2].split(' :', 2)[0].split(' = ', 2)[1]
					if channel.downcase == @channel
						@logger.puts("USERS: " + data.split(@channel + ' :', 2)[1], @logger.joins())
					end
				when "PART"
					nick = data.split('!', 2)[0][1..-1]
					channel = baseTriple[2].split(' :', 2)[0]
					if channel.downcase == @channel
						@subs.delete(nick)
						@logger.puts("PART: " + nick, @logger.joins())
					end
				when "JOIN"
					nick = data.split('!', 2)[0][1..-1]
					channel = baseTriple[2].split(' :', 2)[0]
					if channel.downcase == @channel
						@logger.puts("JOIN: " + nick, @logger.joins())
					end
				else
					#puts data
				end
			end
		end
		@messager.stop
		@logger.close()
	end
end


# Start everything
Settings.load!("config.yaml")
bot = Chocobot.new()
bot.main()