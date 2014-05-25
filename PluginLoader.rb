require './Command.rb'

class PluginLoader

	@@plugins = {}
	@@preCommands = []
	@@postCommands = []
	@@newMsg = []

	def self.load()
		Dir.entries("Plugins").select do |f|
			if File.directory? File.join('Plugins',f) and !(f =='.' || f == '..')
				require "./Plugins/" + f + "/" + f + ".rb"
			end
		end
		for plugin in @@plugins.values
			plugin.addPlugin
		end
	end

	def self.boot(messager, logger)
		for plugin in @@plugins.values
			plugin.getInstance(messager, logger)
		end
		#Timer.getInstance(messager, logger)
	end

	def self.addCommand(cmd)
		@@postCommands << cmd
	end

	def self.addPreCommand(cmd)
		@@preCommands << cmd
	end

	def self.addNewMsg(plugin)
		@@newMsg << plugin
	end

	def self.newMsg()
		for plugin in @@newMsg
			plugin.getInstance.newMsg()
		end
	end

	def self.registerPlugin(name, plugin)
		@@plugins[name] = plugin
	end

	def self.preCommands
		@@preCommands
	end

	def self.postCommands
		@@postCommands
	end
end