require 'confuse/config_item'

module Confuse
  # A {Namespace} is a container to keep configuration data seperate from the
  # rest of the config.
  class Namespace

    attr_reader :items, :supress_warnings_flag, :strict_flag

    def initialize(&block)
      @items = {}
      @supress_warnings_flag = false
      @strict_flag = false
      instance_eval(&block)
    end

    def define(name, &block)
      @items[name] = ConfigItem.new(name, &block)
    end

    def supress_warnings
      @supress_warnings_flag = true
    end

    def strict
      @strict_flag = true
    end

    def [](key, config = nil)
      value = (i = get_item(key)) && i.value
      if value.respond_to?(:call) && !config.nil?
        value.call(config)
      else
        value
      end
    end

    def []=(key, value)
      item = get_item(key) || create_new_key(key, value)
      item && item.value = value
    end

    def keys
      @items.keys
    end

    def create_new_key(key, value)
      if @supress_warnings_flag
        puts "Warning: config includes unknown option '#{key}'"
      end
      @items[key] = ConfigItem.new(key, &nil) unless @strict_flag
    end

    def get_item(key)
      @items[key]
    end

    def merge!(namespace)
      @strict_flag = namespace.strict
      @supress_warnings_flag = namespace.supress_warnings
      @items.merge! namespace.clone.items
    end

    def clone
      c = super
      items = @items.reduce({}) do |m, (k, v)|
        m[k] = v.clone
        m
      end
      c.instance_variable_set(:"@items", items)
      c
    end

  end
end
