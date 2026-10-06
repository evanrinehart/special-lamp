require 'entity'

class Thing < Entity

    def initialize(world, thing_id, table=nil)
        super world, thing_id, world.objects
        @mobs = world.mobs
        @things = world.objects
        @surfaces = world.surfaces
        @devices = world.devices
        @world = world
    end

    def move_to_container(thing_id)
        @things.set(:container_id, @id, thing_id)
        @things.set(:on_surface_id, @id, nil)
    end

    def move_to_surface(surface_id)
        @things.set(:container_id, @id, nil)
        @things.set(:on_surface_id, @id, surface_id)
    end

    def set_location loc
        @things.set(:x, @id, loc[0])
        @things.set(:y, @id, loc[1])
    end

    def clear_location
        @things.set(:x, @id, nil)
        @things.set(:y, @id, nil)
    end

    def on_surface_id
        @things.get(:on_surface_id, @id)
    end

    def on_surface
        surf_id = on_surface_id
        surf_id && Surface.new(@world, surf_id)
    end

    def surfaces
        @surfaces.find_by(:object_id, @id).map do |surf|
            Surface.new(@world, surf.id)
        end
    end

    def x
        @things.get(:x, @id)
    end

    def y
        @things.get(:y, @id)
    end

    def location
        x && y && Vector[x,y]
    end

    def located?
        location != nil
    end

    def outer_surfaces
        surfaces.filter{|x| x.outer?}
    end

    def size
        @things.get(:size, @id)
    end

    def is_mob?
        not @mobs.find_by(:object_id, @id).empty?
    end

    def mob
        mob = @mobs.find_first_by(:object_id, @id)
        mob && Mob.new(@world, mob.id)
    end

    def contents
        @things.find_by(:container_id, @id)
    end

    def get_contents_by_id thing_id
        contents.each do |thing|
            return Thing.new(@world, thing_id) if thing.id == thing_id
        end
        nil
    end

    def entry_id
        @things.get(:entry_id, @id)
    end

    def entry
        surf_id = self.entry_id
        surf_id && Surface.new(@world, surf_id)
    end

    def temperature
        self.on_surface&.measure_temperature
    end

    def inside_temperature
        temps = self.interior_surfaces.map{|x| x.temperature}
        if temps.empty?
            nil
        else
            min = temps.min
            max = temps.max
            (min.to_f + max.to_f) / 2
        end
    end

    def heat_counter
        @things.get(:heat_counter, @id)
    end

    def set_heat_counter value
        @things.set(:heat_counter, @id, value)
    end

    def heat_interior_by amount
        surfs = self.interior_surfaces
        return if surfs.empty?
        winner = amount < 0 ? surfs.max_by{|x| x.temperature} : surfs.min_by{|x| x.temperature}
        temp = winner.temperature
        winner.set_temperature (temp + amount)
        #puts "set #{winner.name} temp to #{temp + amount}"
    end

    def interior_surfaces
        @surfaces.find_by(:object_id, @id).filter{|x| x.outer == false}.map{|x| Surface.new(@world, x.id) }
    end

    def insulation?
        self.devices.filter{|x| x.prototype == :insulation}.empty? == false
    end

    def room_count
        self.interior_surfaces.count
    end

    def devices
        @devices.find_by(:object_id, @id).map{|x| Device.new(@world, x.id) }
    end

    def can_move?
        mob = self.mob
        motor = devices.filter{|x| x.enabled? && x.prototype == :motor}.first
        if mob.nil?
            false
        elsif motor.nil?
            true
        else
            false
        end
    end

end
