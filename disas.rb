#!/usr/bin/env ruby
begin ; require 'rubygems' ; rescue LoadError; end
require 'metasm'

puts Metasm::Shellcode.decode(STDIN.read, Metasm::Ia32.new).disassemble.to_s

