require 'readline'
require 'app'
require 'parser'
require 'generate'

filename = "world.save"
world = load_world(filename) || make_example_world()
app = App.new world
cf = CommandFilter.new app

loop do
    begin
        line = Readline.readline(app.prompt, true)
    rescue Interrupt
        puts ""
        puts "interrupted"
        break
    end

    if line.nil?
        puts ""
        puts "end of input"
        break
    end

    cmd, *args = tokenize line.strip
    if cmd
        done = cf.dispatch cmd, args
        break if done
    else
        app.empty_command()
    end

end
