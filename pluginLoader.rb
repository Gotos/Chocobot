require "./timer.rb"

class PluginLoader
	attr_reader :preCommands, :postCommands

	def initialize
		@preCommands = []
		@postCommands = []
		@newMsg = []
		Timer.addPlugin(self)
	end

	def boot(messager, logger)
		Timer.getInstance(messager, logger)
	end

	def addCommand(cmd)
		@postCommands << cmd
	end

	def addPreCommand(cmd)
		@preCommands << cmd
	end

	def addNewMsg(plugin)
		@newMsg << plugin
	end

	def newMsg()
		for plugin in @newMsg
			plugin.getInstance.newMsg()
		end
	end
end