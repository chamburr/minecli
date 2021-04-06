require "fancyline"
require "json"
require "option_parser"
require "rconcr"

class Minecli
  VERSION = "0.1.0"

  @host = "127.0.0.1"
  @port = 25575
  @password = "minecraft"
  @unit = "minecraft"
  @lines = 10
  @no_logs = false
  @command = ""

  def run
    cli_opts = Process.parse_arguments ENV.fetch "MINECLI_OPTS", ""
    ARGV.concat cli_opts

    OptionParser.parse do |opts|
      opts.banner = <<-BANNER
      Minecraft CLI

      USAGE:
          minecli [OPTIONS] [COMMAND]

      OPTIONS:
      BANNER

      opts.on "--host <host>", "Server host (default: 127.0.0.1)" { |host| @host = host }
      opts.on "--port <port>", "Server port (default: 25575)" { |port| @port = port.to_i }
      opts.on "--password <password>", "Server password (default: minecraft)" { |password| @password = password }
      opts.on "--unit <unit>", "Journalctl unit (default: minecraft)" { |unit| @unit = unit }
      opts.on "--lines <lines>", "Lines of logs to display" { |lines| @lines = lines.to_i }
      opts.on "--no-logs", "Disable journalctl logs" { @no_logs = true }
      opts.on "-h", "--help", "Print the help message and exit" { puts opts; exit }
      opts.on "-v", "--version", "Print version information and exit" { puts "Version #{VERSION}"; exit }

      opts.invalid_option { }
      opts.missing_option { }

      opts.unknown_args do |args, options|
        @command = args.join " "

        if @command.starts_with? "-"
          raise Exception.new "Invalid option: #{args[0]}"
        end
      end
    end

    RCON::Client.open @host, @port, nil do |client|
      valid = client.authenticate @password

      unless valid
        raise Exception.new "Invalid password: #{@password}"
      end

      unless @command.empty?
        resp = client.command @command
        print_color resp
        exit
      end

      if @lines > 0
        output = `sudo journalctl -n #{@lines} --no-pager --output-fields MESSAGE --output json -u #{@unit}`
        output = output.rchop.gsub "\n", ","
        puts JSON.parse("[#{output}]").as_a.map { |entry| entry["MESSAGE"] }.join "\n"
      end

      fancy = Fancyline.new

      fancy.actions.set Fancyline::Key::Control::CtrlH do |ctx|
        ctx.editor.remove_at_cursor -1
      end

      unless @no_logs
        spawn do
          Process.run "sudo journalctl -n 0 -f --output-fields MESSAGE --output json -u #{@unit}", shell: true do |proc|
            loop do
              proc.output.gets.try do |entry|
                fancy.grab_output do
                  puts JSON.parse(entry).as_h["MESSAGE"]
                  if rand(1..1000) == 420
                    case rand 1..5
                    when 1
                      puts "i love ruby! <3 -cham"
                    when 2
                      puts "ruby is great in bed! -cham"
                    when 3
                      puts "threesome with crystal & ruby tonight! -cham"
                    when 4
                      puts "screw june, ruby is waifu <3 -cham"
                    when 5
                      puts "ruby why so s*xy???? -cham"
                    end
                  end
                end
              end
            end
          end
        end
      end

      while input = fancy.readline "> "
        exit if input == "exit"
        resp = client.command input
        print_color resp
      end
    end
  end
end

def print_color(content : String | Nil)
  unless content.nil? || content.empty?
    io = IO::Memory.new 4110
    RCON.colorize io, content

    puts io.to_s.gsub("\033[0m", "\n").rchop
    print "\033[0m"
  end
end

begin
  Minecli.new.run
rescue ex
  puts ex.message
end
