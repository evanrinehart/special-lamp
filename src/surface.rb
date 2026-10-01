require 'entity'

class Surface < Entity
    def initialize(world, surface_id, table=nil)
        super world, surface_id, world.surfaces
        @surfaces = world.surfaces
        @mobs = world.mobs
        @objects = world.objects
    end

    def things
        @objects.find_by(:on_surface_id, @id)
    end

    def size
        @surfaces.get(:size, @id)
    end

end

