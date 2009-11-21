# by Devyn Cairns

require "ext/web-socket-ruby/lib/web_socket.rb"
require "base64"

$wss = WebSocketServer.new("ws://0.0.0.0:3472")

at_exit { puts "\e[1m-- Server off.\e[0m" }

trap("INT") { exit }

puts "\e[1m-- Server listening on port 3472\e[0m"

$wss.run do |ws|
  ws.handshake
  puts "\e[32m-- Connection opened.\e[0m"
  loop do
    print "\e[1mjs>>\e[0m "
    begin
      cmd = gets.chomp
      case cmd
      when /^!!load (.+)/i
        fn = File.expand_path($1)
        if File.exists? fn
          ws.send(Base64.encode64(File.read(fn)))
          result = "\e[32mOK\e[0m"
        else
          result = "\e[31m\e[1mfile not found\e[0m"
        end
      else
        ws.send(Base64.encode64(cmd))
        result = Base64.decode64(ws.receive||break)
      end
      puts "\e[1m=>\e[0m \e[33m#{result}\e[0m"
    rescue Exception
      puts "\e[31m\e[1m#{$!.class.name}:\e[22m #{$!.message}\e[0m"
      break
    end
  end
  puts "\e[31m-- Connection closed.\e[0m"
end
