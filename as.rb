#!/usr/bin/env ruby
begin ; require 'rubygems' ; rescue LoadError; end
require 'metasm'
require 'optparse'

code = ""
asm = nil

opt = OptionParser.new do |o|
  o.banner = "Usage: #{File.basename $0} [opts] < someassmebly.s"
  o.on_tail("-h", "--help", "Show this message.") { puts opts ; exit 1 }
  o.on("-s", "--sled=SIZE", Numeric, "Prepend nop-sled") {|s| code += "\x90"*s }
  o.on("-d", "--int3", "Prepend a debugger trap.") { code += "\xcc" }
  o.on("-f", "--file=FILE", "Read asm from file") {|f| asm = File.read(f) }
end

begin 
  opt.parse!(ARGV)
rescue
  STDERR.puts $!, opt
  exit 1
end

asm ||=  STDIN.read
begin
  code += Metasm::Shellcode.assemble(Metasm::Ia32.new, asm).encoded.data
rescue Metasm::ParseError => e
  STDERR.puts "#{e.class} - #{e}"
  exit 1
end

STDOUT.write code
