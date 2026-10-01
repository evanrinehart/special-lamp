require 'world'
require 'commands'
require 'surface'
require 'thing'
require 'mob'

class CommandFilter

    def initialize(app)
        @app = app
    end

    def dispatch cmd, args
        pp cmd: cmd, args: args

        case cmd
        in "r" then app.reload
        in "save" then app.save
        in "forget" then app.revert
        in "schema" then app.schema
        in "l" then app.look
        in "i" then app.inventory
        in "d" then app.dump args[0]
        in "w" then app.wait args[0].to_i
        in "set" then set args
        in "move" then app.move args[0].to_i, args[1].to_i
        in "drop" then app.drop args[0].to_i
        in "take" then app.take args[0].to_i
        in "addprop" then add_prop args
        in "rmprop" then rm_prop! args
        in "addclass" then add_class args
        in "rmclass" then rm_class args
        in "spawn" then spawn args
        in "delete" then unspawn args
        in "q" then return :stop
        else puts "unknown command"
        end
        nil
    end

    def app
        @app
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

    def unspawn args
        if args.count < 2
            puts "hint: delete <class> <id>"
        else
            k = args[0].to_sym
            id = args[1].to_i
            app.unspawn_entity k, id
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
        player = Mob.new(@world, @player_id)
        surf = player.surface
        if surf.nil?
            puts "(nowhere)"
        else
            roomlook surf.id
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

    def roomlook(surface_id)
        surf = Surface.new(@world, surface_id)
        if surf.exists?
            puts surf.name
            surf.things.each do |thing|
                puts "  #{thing.name}"
            end
        else
            puts "bad surface_id"
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
            table.insert(id, {})
            puts "#{klass} id=#{id} spawned"
        end
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

    def hud_report
        player = Mob.new(@world, @player_id)
        health = player.health
        oxygen = player.oxygen
        puts "HEALTH #{health.value.to_s.rjust(3)}" if health && health.value < health.value_max
        puts "OXYGEN #{oxygen.value.to_s.rjust(3)}" if oxygen && oxygen.value < oxygen.value_max
    end

    def prompt
        "> "
    end

end
