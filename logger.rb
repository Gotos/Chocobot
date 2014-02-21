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
			@file = File.open('bot.log', 'w')
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

	def puts(messages)
		if @general
			@file.write("<" + Time.new().strftime("%H:%M:%S") + "> ")
			@file.puts(messages)
		end
	end

	def close()
		if @general
			@file.close()
		end
	end
end