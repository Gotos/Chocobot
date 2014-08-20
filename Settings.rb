# encoding: utf-8
# Settings-Module based on http://speakmy.name/2011/05/29/simple-configuration-for-ruby-apps/
# and http://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys-21
require 'yaml'

module Settings
  # again - it's a singleton, thus implemented as a self-extended module
  extend self

  @_settings = {}
  @_loaded = false
  attr_reader :_settings

  # This is the main point of entry - we call Settings.load! and provide
  # a name of the file to read as it's argument. We can also pass in some
  # options, but at the moment it's being used to allow per-environment
  # overrides in Rails
  def load!(filename, options = {})
    if !@loaded
      newsets = YAML::load_file(filename)
      newsets.deep_symbolize_keys!
      newsets = newsets[options[:env].to_sym] if \
                                                 options[:env] && \
                                                 newsets[options[:env].to_sym]
      deep_merge!(@_settings, newsets)
      loaded = true
    end
  end

  # Deep merging of hashes
  # deep_merge by Stefan Rusterholz, see http://www.ruby-forum.com/topic/142809
  def deep_merge!(target, data)
    merger = proc{|key, v1, v2|
      Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    target.merge! data, &merger
  end

  def method_missing(name, *args, &block)
    @_settings[name.to_sym] ||
    fail(NoMethodError, "unknown configuration root #{name}", caller)
  end

end

class Hash
  def deep_symbolize_keys!
    deep_transform_keys!{ |key| key.to_sym rescue key }
  end

  def deep_transform_keys!(&block)
    keys.each do |key|
      value = delete(key)
      self[yield(key)] = value.is_a?(Hash) ? value.deep_transform_keys!(&block) : value
    end
    self
  end
end