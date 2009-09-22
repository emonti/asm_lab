#!/usr/bin/env ruby
begin ; require 'rubygems' ; rescue LoadError; end
require 'metasm'
require 'ffi'
require 'optparse'

module LibC
  extend FFI::Library

  # They're for testing shellcode that attempts to restore root privs...
  attach_function :seteuid, [:uint], :int
  attach_function :setegid, [:uint], :int
  attach_function :setuid, [:uint], :int
  attach_function :setgid, [:uint], :int

end


# Renders a FFI memory pointer into a function pointer for ruby using FFI's
# internals. 
#
# This is probably not an intended feature of FFI (yet?), so the interface
# for doing it isn't exactly standard or documented. Our wrapper tries to 
# auto-detect and support the different incantations necessary between versions 
# and platforms.
def make_function_pointer(memp, args, ret)
  funcptr = 
    if FFI.const_defined?("Function")
      ## use FFI::Function for ffi-0.5.0. Dunno if this works in jruby.
      FFI::Function.new FFI.find_type(ret), # return type
                        args,                   # args
                        memp,                 # pointer to our function
                        :convention => :default # calling convention

    elsif FFI.const_defined?("Invoker")
      ## use FFI::Invoker for ffi-0.4.0 - two flavors... yay!
      if RUBY_PLATFORM=='java' # JRuby FFI
        FFI::Invoker.new memp, args, FFI.find_type(ret), ""
      else ## and not Jruby...
        FFI::Invoker.new memp, args, ret, FFI.find_type(ret), "", nil
      end
    else
      raise "oh noes! this version of ffi is totally unfamiliar"
    end

  return funcptr
end
 
raw=gdb=false
code = ""
input = nil

opt = OptionParser.new do |o|
  o.banner = "Usage: #{File.basename $0} [opts] < someassmebly.s"
  o.on_tail("-h", "--help", "Show this message.") { puts opts ; exit 1 }
  o.on("-s", "--sled=SIZE", Numeric, "Add a nop-sled") {|s| code += "\x90"*s }
  o.on("-g", "--debug", "Add a debug trap and spawn gdb via xterm.") { 
    code += "\xcc"
    gdb=true
  }
  o.on("-f", "--file=FILE", "Read input from file") {|f| input = File.read(f) }
  o.on("-r", "--raw", "input as raw bytecode") { raw = true }
  o.on("-d", "--drop_id=RID", Numeric, "drop real privs to RID") do |u| 
    [:setgid, :setuid].each {|m| LibC.send(m, u)}
  end
  o.on("-D", "--drop_eid=EID", Numeric, "drop effective privs to EID") do |u| 
    [:setegid, :seteuid].each {|m| LibC.send(m, u)}
  end
end

begin 
  opt.parse!(ARGV)
rescue
  STDERR.puts $!, opt
  exit 1
end


input ||= STDIN.read

code +=
  if raw
    input
  else # Assemble our code with metasm
    begin
      Metasm::Shellcode.assemble(Metasm::Ia32.new, input).encoded.data
    rescue Metasm::ParseError => e
      STDERR.puts "#{e.class} - #{e}"
      exit 1
    end
  end

# Use FFI to stick that our bytecode somewhere in memory with a known address
memp = FFI::MemoryPointer.from_string(code) 
STDERR.puts "bytecode located at: 0x%0.8x" % memp.address

# optionally launch gdb to attach onto ourself in an xterm
# for debugging.
if gdb==true
  code = "\xcc#{code}" if code[0] != 0xcc # set a trap on entry if needed
  system("xterm -e gdb $(which ruby) #{$$}&")
  sleep 3 # give backgrounded gdb/x11 time to rev up
end


# Create a FFI function pointer to that address with no arguments and a 
# :void return value. XXX we could also have args and another return type.
funcptr = make_function_pointer(memp, [], :void)

## now call the code we stuffed in memory 
ret = funcptr.call()

