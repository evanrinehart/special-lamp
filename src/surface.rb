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

