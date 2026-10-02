require 'entity'

class Edge < Entity
    def initialize(world, edge_id, table=nil)
        super world, edge_id, world.edges
        @surfaces = world.surfaces
        @edges = world.edges
        @world = world
    end

    def surface_id
        @edges.get(:surface_id, @id)
    end

    def to_edge_id
        @edges.get(:to_edge_id, @id)
    end

    def surface
        @surfaces[surface_id]
    end

    def to_edge
        Edge.new(@world, to_edge_id)
    end

    def goes_to_surface? surface_id
        other_surface = to_edge.surface
        other_surface && other_surface.id == surface_id
    end

end

