require 'entity'

class Mob < Entity

    def initialize(world, mob_id, table=nil)
        super world, mob_id, world.mobs
        @mobs = world.mobs
        @objects = world.objects
        @surfaces = world.surfaces
        @powerbars = world.powerbars
        thing_id = @mobs.get(:object_id, mob_id)
        @thing = Thing.new(world, thing_id)
        @world = world
    end

    def thing
        @thing
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

    def health
        health_id = @mobs.get(:health_id, @id)
        health_id && @powerbars[health_id]
    end

    def oxygen
        oxygen_id = @mobs.get(:oxygen_id, @id)
        oxygen_id && @powerbars[oxygen_id]
    end

    def move_to(surface_id)
        @thing.move_to_surface surface_id
    end

end
