#!/usr/bin/env ruby
begin ; require 'rubygems' ; rescue LoadError ; end
require 'ffi'

module LibC
  extend FFI::Library
  attach_function :getenv, [:pointer], :pointer 
end

ARGV.each {|var| puts "#{var} is at 0x%x" % LibC.getenv(var).address }
