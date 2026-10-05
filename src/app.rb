require 'world'
require 'commands'
require 'surface'
require 'edge'
require 'thing'
require 'mob'
require 'player'


class CommandFilter

    def initialize(app)
        @app = app
    end

    def dispatch cmd, args
        #pp cmd: cmd, args: args

        case cmd
        in "l" then look args
        in "ll" then app.look_around
        in "i" then app.inventory
        in "time" then app.print_time
        in "date" then app.print_date

        in "n" then app.go :n
        in "e" then app.go :e
        in "s" then app.go :s
        in "w" then app.go :w
        in "u" then app.go :u
        in "down" then app.go :d
        in "f" then app.go_forward
        in "b" then app.go_back
        in "go" then go args

        in "climb" then climb args
        in "fall" then app.fall
        in "enter" then enter args
        in "leave" then app.leave

        in "range" then range args
        in "goto" then goto args

        in "drive" then drive args

        in "r" then app.reload
        in "save" then app.save
        in "forget" then app.revert
        in "schema" then app.schema
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
        in "reorder" then reorder args
        in "todo" then app.append_todo args[0]
        in "todone" then app.checkoff_todo args[0].to_i
        in "link" then link args
        in "unlink" then unlink args
        in "q" then return :stop
        in "diagesis" then
            puts "The following commands work \"in universe\" so far:"
            puts "  l [direction]"
            puts "  ll"
            puts "  i"
            puts "  go <exit>"
            puts "  goto <object>"
            puts "  climb <object>"
            puts "  fall"
            puts "  enter <object>"
            puts "  leave"
            puts "  wait <n>"
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

    def climb args
        if args.empty?
            puts "hint: climb <object>"
        else
            app.climb args[0].to_i
        end
    end

    def enter args
        if args.empty?
            puts "hint: enter <object>"
        else
            app.enter args[0].to_i
        end
    end

    def range args
        if args.empty?
            puts "hint: range <object>"
        else
            app.range args[0].to_i
        end
    end

    def goto args
        if args.empty?
            puts "hint: goto <object>"
        else
            app.goto args[0].to_i
        end
    end

    def look args
        if args.empty?
            app.look
        else
            if args[0] =~ /\A\d+\z/
                app.look_dir args[0].to_i
            else
                app.look_dir args[0].to_sym
            end
        end
    end

    def drive args
        if args.empty?
            app.drive
        else
            app.drive_vehicle args[0].to_i
        end
    end

    def walk args
        if args.empty?
            puts "hint: walk <minutes>"
        else
            app.walk args[0].to_i
        end
    end

    def reorder args
        if args.count < 2
            puts "hint: reorder <class> <prop> - move prop to the end"
        else
            app.reorder args[0].to_sym, args[1].to_sym
        end
    end

end

class App

    def initialize(world, filename="world.save")
        @filename = filename
        @world = world
        @player = Player.new(world, world.players.first.id)
        @reloadables = [
            'entity.rb',
            'surface.rb',
            'edge.rb',
            'mob.rb',
            'thing.rb',
            'player.rb',
            'powerbar.rb',
            'geometry.rb',
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
        player = self.get_puppet.thing
        surf = player.on_surface
        look_room surf, player
    end

    def look_around
        player = self.get_puppet.thing
        surf = player.on_surface
        glass = surf.glass?
        if surf.outer? || glass
            obj = surf.host_object
            env = obj.on_surface
            if env.nil?
                puts mist
            else
                look_room env, obj, :show_exits => glass
            end
        else
            look_room surf, player
        end
    end

    def look_dir direction
        player = self.get_puppet.thing
        surf = player.on_surface
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
            puts "#{direction}..."
        else
            surf = way.to_surface
            if surf.outer?
                outside = surf.host_object.on_surface
                if outside
                    puts "(outside) #{outside.name}"
                else
                    puts mist
                end
            else
                look_room surf, player, :show_exits => false
            end
        end
    end

    def look_room surface, player, show_exits: true
        if surface.nil?
            puts "(nowhere)"
        else
            if surface.outer?
                env = surface.host_object.on_surface
                puts "#{surface.name} (#{env.name})"
            else
                puts surface.name
            end
            surface.things.each do |thing|
                next if thing.id == player.id
                if surface.far? player, thing
                    dist = surface.measure_separation(player, thing)
                    puts "  #{thing.name} (#{dist[:value]}#{dist[:units]} away)"
                else
                    puts "  #{thing.name}"
                    outers = thing.outer_surfaces
                    outers.each do |surf|
                        surf.things.each do |subthing|
                            puts "    #{subthing.name} (#{surf.name})"
                        end
                    end
                end
            end
            list_exits(surface) if show_exits
            if surface.hot? || surface.cold?
                puts "#{surface.format_temperature}"
            end
        end
    end

    def inventory
        player = self.get_puppet.thing
        things = player.contents
        if things.empty?
            puts "You're empty handed!"
        else
            things.each do |thing|
                puts "  #{thing.name}"
            end
        end
    end

    def drop item_id
        player = self.get_puppet.thing
        thing = player.get_contents_by_id item_id
        surf = player.on_surface
        if thing.nil?
            puts "no such thing"
        elsif surf.nil?
            puts "nowhere to drop it"
        else
            thing.move_to_surface surf.id
            puts "#{thing.name} dropped"
        end
    end

    def take item_id
        puppet = self.get_puppet
        player = puppet.thing
        surface = player.on_surface
        thing = surface.thing_by_id item_id
        if puppet.has_hands? == false
            puts "#{player.name} can't just take stuff"
        elsif thing.nil?
            puts "no such thing"
        elsif thing.is_mob?
            puts "we don't put #{thing.name} in an inventory"
        else
            size_diff = thing.size - player.size
            if size_diff >= 3
                puts "Are you Carmen San Diego?"
            elsif size_diff >= 1
                puts "#{thing.name} is way too big."
            elsif size_diff >= 0
                puts "Not enough strength for that."
            else
                thing.move_to_container player.id
                puts "#{thing.name} taken"
            end
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

    def reorder klass, prop
        if @world[klass].nil?
            puts "no such class"
        elsif @world[klass].has_prop?(prop) == false
            puts "no such prop"
        else
            @world.reorder klass, prop
            puts "moved #{prop} to the end"
        end
    end

    def schema
        @world.dump_schema
    end

    def add_reloadable(filename)
        @reloadables.push filename
    end

    def wait(n)
        if n < 1
            amount = 1
            message = "you wait a minute"
        elsif n < 25
            amount = n
            message = "ready"
        else
            amount = 25
            message = "you get tired of waiting"
        end

        # we directed the game to n minutes.
        # something might need to be done before that.
        # and something might interrupt your waiting.
        # we need to query the time of that next event. do it, then resume waiting (or not).

        puts "needs work"

        #seconds = amount * 60
        #report = spend_up_to(seconds)
        #print_dots (actual / 60)
        #puts "waited #{actual} seconds" if actual != seconds
    end

    def spend_up_to seconds
        t = @player.clock
        n = 0
        seconds.times do
            t += 1
            n += 1
        end
        @player.add_time n
        {:actual => n}
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
        src = Surface.new @world, player.on_surface.id
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
        player = self.get_puppet.thing
        src = Surface.new @world, player.on_surface.id
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
        @player.mob
    end

    def get_puppet
        avatar = self.get_avatar
        vehicle = avatar.vehicle
        vehicle || avatar
    end

    def go direction
        player = self.get_puppet.thing
        surf = player.on_surface
        here = surf
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

        geo = surf.geometry

        if way.nil? && geo.nil?
            puts "way not found"
        elsif way.nil?
            point1 = player.location
            tn = geo.tangent_from_compass point1, direction
            speed = player.mob.speed
            vel = geo.make_velocity tn, speed
            ttb = geo.time_to_boundary point1, vel
            if ttb && ttb < 60.0
                puts "that way surface ends. better stay put for now"
            else
                point2 = geo.motion point1, vel, 60.0
                player.set_location point2
                puts "moving along surface for 1 minute"
                print_dots 6
                #@player.add_time 60
                spend_up_to 60
                look
            end
        else
            dest = way.to_surface || here.surroundings_surface

            if dest.nil?
                puts "no way"
            elsif player.size > dest.size
                puts "As it stands you'd never fit."
            elsif way.blocked?
                puts "That way is blocked."
            else
                transfer_object player, here, dest
                #puts "moved to #{dest.name}"
                look
                spend_up_to 1
            end
        end
    end

    def climb thing_id
        player = self.get_puppet.thing
        surface = player.on_surface
        here = surface
        thing = surface.thing_by_id thing_id
        if thing.nil?
            puts "no such thing"
        elsif thing_id == player.id
            puts "ill-advised"
        elsif player.size > thing.size
            puts "ill-advised"
        elsif surface.far? player, thing
            puts "it's too far (goto #{thing_id}?)"
        else
            surfs = thing.outer_surfaces
            if surfs.empty?
                puts "#{thing.name} can't be climbed"
            else
                surf = surfs.first
                player.move_to_surface surf.id
                if surf.simple?
                    player.clear_location
                else
                    # to be revisited
                    puts "climb onto non-simple surface (needs work)"
                    player.set_location Vector[0.0,0.0]
                end
                #puts "climbing onto #{thing.name}"
                look
                spend_up_to 1
            end
        end
    end

    def fall
        player = self.get_puppet.thing
        here = player.on_surface
        if here.nil? || !here.outer?
            puts "you can't fall from here"
        else
            thing = player.on_surface.host_object
            if thing.nil? || thing.on_surface_id.nil?
                puts "nowhere to fall to"
            else
                surroundings = thing.on_surface
                transfer_object player, here, surroundings
                #puts "moved from #{thing.name} to #{surroundings.name}"
                look
                spend_up_to 1
            end
        end
    end

    def transfer_object thing, from_surface, to_surface
        # good attempt to standardize movement but doesn't deal with geometric transfers.
        # and doesn't deal with moving onto a "smaller" geometry from a larger one.
        # only implements moving to simple, or exiting to surroundings.
        if to_surface.simple?
            thing.move_to_surface to_surface.id
            thing.clear_location
        else
            host = from_surface.host_object
            thing.move_to_surface to_surface.id
            thing.set_location host.location
        end
    end

    def go_forward
        puts "CHARGE AHEAD!!! (no effect)"
    end

    def go_back
        avatar = self.get_avatar
        if avatar.driving_id
            stop_driving
            look
        else
            puts "backtracking... (no effect)"
        end
    end

    def list_exits surface
        entries = []
        surface.edges.each do |edge|
            dest = edge.to_surface
            sc = edge.shortcut
            label = sc ? sc.to_s : "go #{edge.index}"
            to_name = dest ? dest.name : "outside"
            entries.push({:label => label, :form => edge.form, :to_name => to_name})
        end
        width = entries.map{|x| x[:label].length}.max
        entries.each do |entry|
            puts "#{entry[:label].ljust(width)} - #{entry[:form]} to #{entry[:to_name]}"
        end
    end

    def range thing_id
        player = self.get_puppet.thing
        surface = player.on_surface
        thing = select_thing thing_id, player
        if thing_id == player.id
            puts "You Are Here"
        elsif thing.nil?
            puts "not in this area"
        elsif surface.simple?
            puts "range to #{thing.name}: it's right here"
        else
            compute_range(surface, player, thing) => meters: meters, value: value, units: units
            if meters <= 5
                puts "range to #{thing.name}: it's right here"
            else
                puts "range to #{thing.name}: #{value}#{units}"
            end
        end
    end

    def compute_range surface, player, thing
        surface.measure_separation player, thing
    end

    def goto thing_id
        player = self.get_puppet.thing
        surface = player.on_surface
        thing = select_thing thing_id, player
        if thing_id == player.id
            puts "You're Already Here"
        elsif thing.nil?
            puts "no strange thing"
        elsif surface.simple?
            puts "You're there!"
        else
            meters = compute_range(surface, player, thing)[:meters]
            if meters <= 5
                puts "You're there!"
            else
                speed = player.mob.speed
                puts "move #{meters.round} meters toward #{thing.name}"
                print_dots 6
                puts "takes #{format_time(meters / speed)}"
                player.set_location thing.location
                seconds = (meters / speed).round
                #@player.add_time seconds
                spend_up_to seconds
            end
        end
    end

    def select_thing thing_id, player
        return nil if not @world.objects.exists?(thing_id)
        return nil if thing_id == player.id
        thing = Thing.new(@world, thing_id)
        surface = player.on_surface
        #return thing if surface.host_object_id == thing_id
        return thing if thing.on_surface_id == surface.id
    end

    def format_time seconds
        if seconds < 60
            "#{seconds.round} seconds"
        elsif seconds < 3600
            "#{seconds.round / 60} minutes"
        else
            "#{seconds.round / 3600} hours #{(seconds.round % 3600) / 60} minutes"
        end
    end

    def drive
        puppet = self.get_puppet
        player = puppet.thing
        here = player.on_surface
        if here.has_controls? == false
            puts "no controls here"
        elsif puppet.has_hands? == false
            puts "#{player.name} can't drive something"
        else
            host = here.host_object
            if host.nil?
                puts "these controls go nowhere"
            elsif host.is_mob? == false
                puts "#{host.name} is not mobile"
            else
                puppet.set_driving host.mob.id
                puts "You take control of #{host.name} (b to stop driving)"
                look
            end
        end
    end

    def stop_driving
        avatar = self.get_avatar
        avatar.set_driving nil
    end

    def drive_vehicle thing_id
    end

    def enter thing_id
        player = self.get_puppet.thing
        here = player.on_surface
        thing = select_thing thing_id, player
        if thing.nil?
            puts "no such thing"
        elsif here.far? player, thing
            puts "it's too far"
        else
            to_surf = thing.entry
            if to_surf.nil?
                puts "I think not"
            else
                # to be revisited, to_surf might have geometry (?)
                player.move_to_surface to_surf.id
                player.clear_location
                look
                spend_up_to 1
            end
        end
    end

    def leave
        player = self.get_puppet.thing
        here = player.on_surface
        edge = here.single_exit || here.escape_hatches.first
        if edge.nil?
            puts "no immediate way outside"
        else
            to_surf = edge.to_surface || here.surroundings_surface
            if to_surf.nil?
                puts "no way"
            else
                transfer_object player, here, to_surf
                look
                spend_up_to 1
            end
        end
    end

    def print_time
        puts "#{@player.show_time}"
    end

    def print_date
        d = @player.day
        puts "#{d + 1}"
    end

    def print_dots n
        n.times do
            print "."
            sleep 0.1
        end
        puts ""
    end

    def hud_report
    end

    def mist
        "A featureless cyan mist"
    end

    def prompt
        player = self.get_avatar
        vehicle = player.vehicle
        vehicle ? "#{vehicle.name}> " : "> "
    end

    def empty_command
        hud_report
    end

end
