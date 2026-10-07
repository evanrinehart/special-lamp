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

    def form
        @edges.get(:form, @id)
    end

    def blocked?
        @edges.get(:blocked, @id)
    end

    def passable?
        return false if blocked?
        d = self.door
        d.nil? || d.open?
    end

    def door
        did = self.door_id
        did && Door.new(@world, did)
    end

    def door_id
        @edges.get(:door_id, @id)
    end

    def index
        @edges.get(:index, @id)
    end

    def shortcut
        @edges.get(:shortcut, @id)
    end

    def center
        x = @edges.get(:center_x, @id)
        y = @edges.get(:center_y, @id)
        x && y && Vector[x,y]
    end

    def origin
        x = @edges.get(:origin_x, @id)
        y = @edges.get(:origin_y, @id)
        x && y && Vector[x,y]
    end

    def radius
        geo = surface.geometry
        geo && geo.distance(center, origin)
    end

    def surface
        Surface.new(@world, surface_id)
    end

    def to_edge
        eid = self.to_edge_id
        eid && Edge.new(@world, to_edge_id)
    end

    def goes_to_surface? surface_id
        other_surface = to_edge.surface
        other_surface && other_surface.id == surface_id
    end

    def goes_outside?
        return true if self.to_edge_id.nil?
        to_surface.outer?
    end

    def to_surface
        if self.to_edge_id
            to_edge.surface
        else
            nil
        end
    end

end

