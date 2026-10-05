require 'entity'

class Mob < Entity

    def initialize(world, mob_id, table=nil)
        super world, mob_id, world.mobs
        @mobs = world.mobs
        @objects = world.objects
        @surfaces = world.surfaces
        thing_id = @mobs.get(:object_id, mob_id)
        @thing = Thing.new(world, thing_id)
        @world = world
    end

    def thing
        @thing
    end

    def driving_id
        @mobs.get(:driving_id, @id)
    end

    def vehicle
        vid = self.driving_id
        vid && Mob.new(@world, vid)
    end

    def set_driving vehicle_id
        @mobs.set(:driving_id, @id, vehicle_id)
    end

    def has_hands?
        @mobs.get(:hands, @id)
    end

    def has_pilot?
        @mobs.find_first_by(:driving_id, @id) != nil
    end

    def name
        @thing.name
    end

    def surface
        surf_id = @thing.on_surface_id
        surf_id && Surface.new(@world, surf_id)
    end

    def things
        @objects.find_by(:container_id, @thing.id)
    end

    def speed
        @mobs.get(:speed, @id)
    end

    def move_to(surface_id)
        @thing.move_to_surface surface_id
    end

end
