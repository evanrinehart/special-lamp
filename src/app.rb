require 'world'
require 'commands'
require 'surface'
require 'edge'
require 'thing'
require 'mob'
require 'door'
require 'player'
require 'temperature'
require 'time'
require 'names'

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
        in "temp" then app.print_temp

        in "match" then app.match args[0]

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

        in "check" then check args

        in "r" then app.reload
        in "save" then app.save
        in "forget" then app.revert
        in "schema" then app.schema
        in "d" then dump args
        in "df" then dump_file args
        in "wait" then app.wait_minutes args[0].to_i
        in "." then app.wait_seconds args[0].to_i
        in "set" then set args
        in "move" then app.move args[0].to_i, args[1].to_i
        in "drop" then app.drop args[0].to_i
        in "take" then app.take args[0].to_i
        in "addprop" then add_prop args
        in "rmprop" then rm_prop! args
        in "setdefault" then setdefault args
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
            puts "  time"
            puts "  temp"
            puts "  range"
            puts "  drive"
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

    def setdefault args
        if args.count < 3
            puts "hint: setdefault <class> <prop> <value>"
        else
            k = args[0].to_sym
            p = args[1].to_sym
            v = parse_value(args[2])
            app.set_default k, p, v
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

    def check args
        if args.empty?
            puts "check <object>"
        else
            app.check args[0].to_i
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
        @driver = TimeDriver.new @world, @player
        @reloadables = [
            'entity.rb',
            'surface.rb',
            'edge.rb',
            'mob.rb',
            'thing.rb',
            'device.rb',
            'door.rb',
            'player.rb',
            'time.rb',
            'temperature.rb',
            'geometry.rb',
            'names.rb',
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
            env = surface.host_object&.on_surface
            if surface.outer? && env
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
            if surf.simple?
                thing.clear_location
            else
                thing.set_location Vector[0.0,0.0]
            end
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

    def set_default klass, prop, value
        table = @world[klass]
        if table.nil?
            puts "no such class"
        elsif table.has_prop?(prop) == false
            puts "no such prop"
        else
            table.set_default prop, value
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

    def wait_seconds n
        n = 1 if n < 1
        if n > 90
            puts "the wait <minutes> command might be better for that"
        else
            puts "waiting #{n} second#{n > 1 ? 's' : ''}"
            count = @driver.try_advance_seconds n
            puts "events: #{@driver.get_events}"
            if count < n
                puts "only #{count} second#{count > 1 ? 's' : ''} passed"
            end
        end
    end

    def wait_minutes(n)
        if n <= 1
            puts "waiting 1 minute"
            minutes = 1
        elsif n <= 25
            minutes = n
        else
            minutes = 25
            impatient = true
        end

        minutes.times do
            count = @driver.try_advance_seconds 60
            puts "events: #{@driver.get_events}"
            if count < 60
                puts "you stop waiting early"
                return
            end
        end

        puts "you got tired of waiting" if impatient
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

    # this assumes point1 and point2 are on the same surface, no bounds check
    # something else needs to plan to finish at edge boundary (and resume).
    # issues, can't be interrupted
    def geo_go surface, point1, point2, seconds, thing
        geo = surface.geometry
        count = 0
        seconds.times do
            count += 1
            loc = geo.interpolate point1, point2, (count.to_f / seconds)
            thing.set_location loc
            @driver.advance_second
            if count % 60 == 0
                puts "<#{@player.show_time}> trudge" unless seconds <= 60
                sleep 0.7 unless seconds <= 60
            end
        end
        thing.set_location point2
    end

    # busted. Called by 'go' when moving on a surface.
    # problem is it doesn't know about internal "cutout" edges.
    # we should not go past them, at least. Ideally, we traverse the edges.
    def whaa surface, point1, velocity, delta_t, player

        # so, this causes you to go in some direction at some speed for some time.
        # if you reach a boundary, universe collapses.

        # DOESN'T KNOW ABOUT CUTOUTS. SHOULD IT?

        geo = surface.geometry
        ttb = geo.time_to_boundary point1, velocity
        if ttb && ttb < 1.0
            puts "I refuse to go another step!"
        elsif ttb && ttb < delta_t
            short_t = ttb.floor
            point2 = geo.motion point1, velocity, short_t.to_f
            geo_go surface, point1, point2, short_t, player
            puts "the is the end for now"
            look
        else
            point2 = geo.motion point1, velocity, delta_t.to_f
            geo_go surface, point1, point2, delta_t, player
            look
        end
    end

    def simple_go from_surface, to_surface, player
        if to_surface.nil?
            puts "nowhere to go"
        elsif not to_surface.would_fit?(player)
            puts "As it stands you'd never fit."
        elsif to_surface.geometry
            loc = from_surface.host_object.location
            player.move_to_surface to_surface.id
            player.set_location loc
            @driver.advance_second
            look
        else
            player.move_to_surface to_surface.id
            player.clear_location
            @driver.advance_second
            look
        end
    end

    def go direction
        player = self.get_puppet.thing
        here = player.on_surface
        geo = here.geometry # no geometry = simple surface

        nsew = [:n, :s, :e, :w].include? direction

        if geo && nsew # moving rectilinear on a geometric surface
            point1 = player.location
            tangent = geo.tangent_from_compass point1, direction
            speed = player.mob.speed
            vel = geo.make_velocity tangent, speed
            whaa here, point1, vel, 60, player
        elsif geo
            puts "it would be nice"
        else # moving from simple surface
            way = here.find_way direction
            if way.nil?
                puts "no way"
            elsif way.passable? == false
                puts "it's blocked"
            else
                there = way.to_surface || here.surroundings_surface
                simple_go here, there, player
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
                simple_go here, surfs.first, player
            end
        end
    end

    def fall
        player = self.get_puppet.thing
        here = player.on_surface
        if here.nil? || !here.outer?
            puts "you can't fall from here"
        else
            there = here.host_object&.on_surface
            simple_go here, there, player
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
                point1 = player.location
                point2 = thing.location
                speed = player.mob.speed
                effect = speed >= 10.0 ? :fast : :slow
                time = (meters / speed).ceil
                puts "move #{meters.round} meters toward #{thing.name}"
                puts "taking #{format_time(meters / speed)} ... "
                geo_go surface, point1, point2, time, player
                look
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
                simple_go here, to_surf, player
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
                simple_go here, to_surf, player
            end
        end
    end

    def check thing_id
        player = self.get_puppet.thing
        thing = select_thing thing_id, player
        if thing.nil?
            puts "no such thing"
        else
            puts "#{thing.name}:"
            thing.devices.each do |dev|
                puts "#{dev.quality} #{dev.prototype} #{dev.enabled? == false ? "(disabled)" : ""}"
            end
        end
    end

    def print_time
        puts "#{@player.show_time}"
    end

    def print_temp
        player = self.get_puppet.thing
        here = player.on_surface
        puts "#{here.format_temperature}"
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

    def match str
        ns = NameSearch.new @world
        player = self.get_puppet.thing
        here = player.on_surface
        surfs = visible_surfaces_from here, player.location

        results = ns.find_by_fragment surfs, [player], str
        results.each do |r|
            puts "#{r.id} #{r.name} on #{r.on_surface_id.inspect} or #{r.container_id.inspect}"
        end
        puts "#{results.count} results"

    end

    def visible_surfaces_from surface, point
        results = []
        results.push surface

        geo = surface.geometry
        surface.things.each do |thing|
            next if geo && geo.distance(point, thing.location) > 5
            thing.outer_surfaces.each{|surf| results.push surf}
        end

        host = surface.host_object
        if host && surface.outer?
            env = host&.on_surface
            if env
                results.push env

                geo = env.geometry
                loc = host.location
                env.things.each do |thing|
                    next if geo && geo.distance(loc, thing.location) > 5
                    thing.outer_surfaces.each do |surf|
                        next if surf.id == surface.id
                        results.push surf
                    end
                end
            end
        end

        results
    end

end
