require 'world'
require 'commands'
require 'surface'
require 'edge'
require 'thing'
require 'mob'


class CommandFilter

    def initialize(app)
        @app = app
    end

    def dispatch cmd, args
        #pp cmd: cmd, args: args

        case cmd
        in "n" then app.go :n
        in "e" then app.go :e
        in "s" then app.go :s
        in "w" then app.go :w
        in "u" then app.go :u
        in "down" then app.go :d
        in "f" then app.go_forward
        in "b" then app.go_back
        in "go" then go args
        in "exits" then app.list_exits

        in "r" then app.reload
        in "save" then app.save
        in "forget" then app.revert
        in "schema" then app.schema
        in "l" then app.look
        in "i" then app.inventory
        in "d" then dump args
        in "df" then dump_file args
        in "wait" then app.wait args[0].to_i
        in "." then app.wait args[0].to_i
        in "set" then set args
        in "move" then app.move args[0].to_i, args[1].to_i
        in "drop" then app.drop args[0].to_i
        in "take" then app.take args[0].to_i
        in "addprop" then add_prop args
        in "rmprop" then rm_prop! args
        in "addclass" then add_class args
        in "rmclass" then rm_class args
        in "spawn" then spawn args
        in "spawnid" then spawnid args
        in "delete" then unspawn args
        in "todo" then app.append_todo args[0]
        in "todone" then app.checkoff_todo args[0].to_i
        in "link" then link args
        in "unlink" then unlink args
        in "q" then return :stop
        in "diagesis" then
            puts "The following commands work \"in universe\" so far:"
            puts "  l"
            puts "  i"
            puts "  exits"
            puts "  go <exit>"
            puts "  . <n>"
            puts "  take <object>"
            puts "  drop <object>"
        else puts "unknown command"
        end
        nil
    end

    def app
        @app
    end

    def link args
        if args.count < 1
            puts "link <target>"
        else
            app.link args[0].to_i
        end
    end

    def unlink args
        if args.count < 1
            puts "unlink <target>"
        else
            app.unlink args[0].to_i
        end
    end

    def set args
        if args.count < 4
            puts "set <class> <id> <prop> <value>"
        else
            k = args[0].to_sym
            id = args[1].to_i
            p = args[2].to_sym
            v = parse_value(args[3])
            app.set k, id, p, v
        end
    end

    def add_prop args
        if args.count < 3
            puts "hint: addprop <class> <prop> <value>"
        else
            k = args[0].to_sym
            p = args[1].to_sym
            v = parse_value(args[2])
            app.add_prop k, p, v
        end
    end

    def rm_prop! args
        if args.count < 2
            puts "hint: rmprop <class> <prop>"
        else
            k = args[0].to_sym
            p = args[1].to_sym
            app.rm_prop! k, p
        end
    end

    def add_class args
        if args.count < 1
            puts "hint: addclass <class>"
        else
            k = args[0].to_sym
            app.add_class k
        end
    end

    def rm_class args
        if args.count < 1
            puts "hint: rmclass <class>"
        else
            k = args[0].to_sym
            app.delete_class k
        end
    end

    def spawn args
        if args.count < 1
            puts "hint: spawn <class>"
        else
            k = args[0].to_sym
            app.spawn_entity k
        end
    end

    def spawnid args
        if args.count < 2
            puts "spawnid <class> <id> is only for restoring a text dump"
            puts "spawning an entity with a pre-existing ID would be bad"
            puts "no checking will be done here"
        else
            k = args[0].to_sym
            id = args[1].to_i
            app.spawn_entity_with_id k, id
        end
    end

    def unspawn args
        if args.count < 2
            puts "hint: delete <class> <id>"
        else
            k = args[0].to_sym
            id = args[1].to_i
            app.unspawn_entity k, id
        end
    end

    def dump args
        if args.empty?
            app.dump nil
        else
            app.dump args[0]
        end
    end

    def dump_file args
        if args.empty?
            puts "hint: df <filename>"
            puts "file will be overwritten without warning"
        else
            app.dump_file args[0]
        end
    end

    def go args
        if args.empty?
            puts "hint: go <letter or number>"
        elsif args[0] =~ /\A\d+\z/
            app.go args[0].to_i
        else
            app.go args[0].to_sym
        end
    end

end

class App

    def initialize(world, filename="world.save")
        @filename = filename
        @world = world
        @player_id = 5
        @reloadables = [
            'entity.rb',
            'surface.rb',
            'edge.rb',
            'mob.rb',
            'thing.rb',
            'app.rb'
        ]
    end

    def reload
        @reloadables.each{|filename| load(filename) }
        puts "reloaded"
    end

    def revert
        @world = load_world(@filename)
        puts "world reloaded from file"
    end

    def dump(name)
        if name.nil?
            @world.dump
        else
            table = @world[name.to_sym]
            if table.nil?
                puts "not found"
            else
                table.dump
            end
        end
    end

    def save
        @world.save_world(@filename)
        puts "world saved"
    end

    def look
        player = Mob.new(@world, @player_id).thing
        surf = player.surface
        if surf.nil?
            puts "(nowhere)"
        else
            puts surf.name
            surf.things.each do |thing|
                next if thing.id == player.id
                puts "  #{thing.name}"
            end
            list_exits
        end
    end

    def inventory
        player = Mob.new(@world, @player_id)
        things = player.things
        if things.empty?
            puts "you're empty handed!"
        else
            things.each do |thing|
                puts "  #{thing.name}"
            end
        end
    end

    def drop item_id
        player = Mob.new(@world, @player_id).thing
        surf = player.surface
        thing = Thing.new(@world, item_id)
        if surf.nil?
            puts "nowhere to drop it"
        elsif thing.invalid?
            puts "no such thing"
        else
            thing.move_to_surface surf.id
            puts "#{thing.name} dropped"
        end
    end

    def take item_id
        player = Mob.new(@world, @player_id).thing
        thing = Thing.new(@world, item_id)
        if thing.invalid?
            puts "no such thing"
        else
            thing.move_to_container player.id
            puts "#{thing.name} taken"
        end
    end

    def set(klass, id, field, value)
        table = @world[klass]
        if table.nil?
            puts "no such class"
            return
        end
        if !table.has_prop? field
            puts "no such property"
            return
        end
        if !table.exists? id
            puts "no such id (#{id.inspect})"
            return
        end
        table.set(field, id, value)
        puts "it is done"
    end

    def move(thing_id, surface_id)
        thing = Thing.new(@world, thing_id)
        surf = Surface.new(@world, surface_id)
        if thing.size > surf.size
            puts "that won't fit"
        else
            thing.move_to_surface surface_id
            puts "#{thing.name} moved to #{surf.name}"
        end
    end

    # the arguments all have the correct type and exist
    def add_prop(klass, prop, value)
        table = @world[klass]
        if table.nil?
            puts "no such class"
        elsif table.has_prop? prop
            puts "prop already exists"
        else
            table.add_prop(prop, value)
            puts "#{prop} added"
        end
    end

    def rm_prop!(klass, prop)
        table = @world[klass]
        if table.nil?
            puts "no such class"
        elsif not table.has_prop?(prop)
            puts "no such prop"
        else
            table.delete_prop!(prop)
            puts "dropped #{table.population} values"
        end
    end

    def add_class name
        table = @world[name]
        if table.nil?
            @world.add_empty_class name
            puts "#{name} added"
        else
            puts "class #{name} already exists"
        end
    end

    def delete_class name
        table = @world[name]
        if table.nil?
            puts "class #{name} not found"
        else
            n = table.population
            @world.delete_class name
            puts "class #{name} deleted (#{n} entries gone)"
        end
    end

    def spawn_entity klass
        table = @world[klass]
        if table.nil?
            puts "no such class"
        else
            id = @world.generate_id
            spawn_entity_id klass, id
            puts "#{klass} id=#{id} spawned"
        end
    end

    def spawn_entity_id klass, id
        table = @world[klass]
        table.insert(id, {})
    end

    def unspawn_entity klass, id
        table = @world[klass]
        if table.nil?
            puts "no such class"
        else
            table.delete id
            puts "#{klass} id=#{id} deleted"
        end
    end

    def schema
        @world.dump_schema
    end

    def add_reloadable(filename)
        @reloadables.push filename
    end

    def empty_command
        hud_report
    end

    def wait(n)
        if n < 1
            puts "how long?"
            return
        end

        if n < 25
            n.times do
                print '.'
                sleep 0.1
            end
            puts ""
            puts "ready"
            hud_report
        else
            25.times do
                print '.'
                sleep 0.1
            end
            puts ""
            puts "you get tired of waiting"
            hud_report
        end
    end

    def append_todo note
        id = @world.generate_id
        @world[:todos].insert(id, {:note => note})
        puts "noted (id=#{id})"
    end

    def checkoff_todo id
        table = @world[:todos]
        if table.exists? id
            @world[:todos].set(:check, id, "CHECK")
            puts "check-o-roonie"
        else
            puts "todo #{id} not found"
        end
    end

    def dump_file filename
        file = File.open filename, 'w'
        @world.dump_text file
        file.close
        puts "wrote #{filename}"
    end

    def link dest_id
        player = get_avatar()
        src = Surface.new @world, player.surface.id
        dst = Surface.new @world, dest_id
        if src.nil?
            puts "no source"
        elsif dst.invalid?
            puts "destination not found"
        else
            n1 = src.edge_max_plus
            n2 = dst.edge_max_plus
            e1 = @world.generate_id
            e2 = @world.generate_id
            edges = @world.edges
            edges.insert e1, :surface_id => src.id, :index => n1, :to_edge_id => e2
            edges.insert e2, :surface_id => dst.id, :index => n2, :to_edge_id => e1
            puts "linked to #{dst.name}"
        end
    end

    def unlink dest_id
        player = self.get_avatar
        src = Surface.new @world, player.surface.id
        dst = Surface.new @world, dest_id
        if src.nil?
            puts "no source"
        elsif dst.invalid?
            puts "destination not found"
        else
            n = src.delete_edges_to dst.id
            puts "deleted #{n} edges"
        end
    end

    def get_avatar
        Mob.new(@world, @player_id).thing
    end

    def hud_report
        player = Mob.new(@world, @player_id)
        health = player.health
        oxygen = player.oxygen
        puts "HEALTH #{health.value.to_s.rjust(3)}" if health && health.value < health.value_max
        puts "OXYGEN #{oxygen.value.to_s.rjust(3)}" if oxygen && oxygen.value < oxygen.value_max
    end

    def go direction
        player = self.get_avatar
        surf = player.surface
        edges = surf.edges.sort_by{|e| e.index}
        way = nil
        edges.each do |e|
            if e.shortcut == direction
                way = e
                break
            elsif e.index == direction
                way = e
                break
            end
        end
        if way.nil?
            puts "way not found (see exits command)"
        else
            dest = way.to_surface
            if player.size <= dest.size
                player.move_to_surface dest.id
                puts "moved to #{dest.name}"
            else
                puts "As it stands you'd never fit."
            end
        end
    end

    def go_forward
        puts "CHARGE AHEAD!!!"
    end

    def go_back
        puts "backtracking..."
    end

    def list_exits
        player = self.get_avatar
        surf = player.surface
        entries = []
        surf.edges.each do |edge|
            dest = edge.to_surface
            sc = edge.shortcut
            label = sc ? sc.to_s : "go #{edge.index}"
            entries.push({:label => label, :form => edge.form, :to_name => dest.name})
        end
        width = entries.map{|x| x[:label].length}.max
        entries.each do |entry|
            puts "#{entry[:label].ljust(width)} - #{entry[:form]} to #{entry[:to_name]}"
        end
    end

    def prompt
        "> "
    end

end
