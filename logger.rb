require './settings.rb'

class Logger
	def initialize()
		Settings.load!("config.yaml")
		logcon		= Settings.logging
		@general	= logcon[:general]
		@joins		= logcon[:joins]
		@op			= logcon[:op]
		@messages	= logcon[:messages]
		@ts			= logcon[:timestamp]
		@tsp		= logcon[:timestampPre]
		@tss		= logcon[:timestampSuf]

	end

	def init_file()
		date = Time.new().strftime("%Y-%m-%d")
		if @date == nil || @date != date
			@date = date
			if @file != nil && !@file.closed?()
				@file.close()
			end
			@file = File.open(@date + '.log', 'a')
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
		string = @tsp + Time.new().strftime(@ts) + @tss + " "
		string += messages
		$stdout.puts(string)
		if @general && log
			init_file()
			@file.puts(string)
		end
	end

	def close()
		if @file != nil && !@file.closed?()
			@file.close()
		end
	end
end