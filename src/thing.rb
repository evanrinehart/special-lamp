require 'entity'

class Thing < Entity

    def initialize(world, thing_id, table=nil)
        super world, thing_id, world.objects
        @mobs = world.mobs
        @things = world.objects
        @surfaces = world.surfaces
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

    def on_surface_id
        @things.get(:on_surface_id, @id)
    end

    def surface
        surf_id = on_surface_id
        surf_id && Surface.new(@world, surf_id)
    end

    def size
        @things.get(:size, @id)
    end

    def is_mob?
        not @mobs.find_by(:object_id, @id).empty?
    end

end
