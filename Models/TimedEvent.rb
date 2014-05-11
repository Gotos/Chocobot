require 'rubygems'
require 'data_mapper'

class TimedEvent
	include DataMapper::Resource

	property :name,				String, :required => true, :key => true
	property :msg,				Text, :required => true
	property :time,				Integer, :required => true
	property :messagesPassed,	Integer, :required => true
	property :t,				Integer, :default => -1
	property :mc,				Integer, :default => -1
end
