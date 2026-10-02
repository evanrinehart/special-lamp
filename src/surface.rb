require 'entity'

class Surface < Entity
    def initialize(world, surface_id, table=nil)
        super world, surface_id, world.surfaces
        @surfaces = world.surfaces
        @mobs = world.mobs
        @objects = world.objects
        @edges = world.edges
        @world = world
    end

    def things
        @objects.find_by(:on_surface_id, @id)
    end

    def size
        @surfaces.get(:size, @id)
    end

    def outer
        @surfaces.get(:outer, @id)
    end

    def host_object_id
        @surfaces.get(:object_id, @id)
    end

    def host_object
        thing_id = self.host_object_id
        thing_id && Thing.new(@world, thing_id)
    end

    def thing_by_id thing_id
        things.each do |thing|
            return Thing.new(@world, thing_id) if thing.id == thing_id
        end
        nil
    end

    def edge_max_plus
        indices = @edges.find_by(:surface_id, @id).map{|x| x.index}
        indices.empty? ? 0 : indices.max + 1
    end

    def edges
        @edges.find_by(:surface_id, @id).map{|x| Edge.new(@world, x.id)}
    end

    def delete_edges_to surface_id
        delete_list = []
        edges.each do |edge|
            if edge.goes_to_surface? surface_id
                delete_list.push edge.id
                delete_list.push edge.to_edge_id
            end
        end
        n = delete_list.count
        delete_list.each do |id|
            @edges.delete id
        end
        n
    end

end

