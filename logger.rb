require './settings.rb'

class Logger
	def initialize()
		Settings.load!("config.yaml")
		logcon		= Settings.logging
		@general	= logcon[:general]
		@joins		= logcon[:joins]
		@op			= logcon[:op]
		@messages	= logcon[:messages]
		if @general
			@file = File.open('bot.log', 'a')
			@file.sync = true
		end
	end

	def joins()
		@general && @joins
	end

	def op()
		@general && @op
	end

	def messages()
		@general && @messages
	end

	def puts(messages, log = false)
		string = "<" + Time.new().strftime("%H:%M:%S") + "> "
		string += messages
		$stdout.puts(string)
		if @general && log
			@file.puts(string)
		end
	end

	def close()
		if @general
			@file.close()
		end
	end
end