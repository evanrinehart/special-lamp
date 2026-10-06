require 'entity'
require 'geometry'

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
        @objects.find_by(:on_surface_id, @id).map {|o| Thing.new(@world, o.id) }
    end

    def size
        @surfaces.get(:size, @id)
    end

    def outer?
        @surfaces.get(:outer, @id)
    end

    def glass?
        @surfaces.get(:glass, @id)
    end

    def has_controls?
        @surfaces.get(:controls, @id)
    end

    def geometry_id
        @surfaces.get(:geometry_id, @id)
    end


    def far? thing1, thing2
        if simple?
            false
        else
            geometry.distance(thing1.location, thing2.location) > 5
        end
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

    def escape_hatches
        edges.filter do |e|
            e.to_edge_id.nil? || (e.goes_outside? && e.open?)
        end
    end

    def single_exit
        all_edges = self.edges
        if all_edges.count == 1
            e = all_edges.first
            e.passable? ? e : nil
        else
            nil
        end
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

    def geometry
        # should instead pick the right geometry, not always Tube
        gid = self.geometry_id
        return nil if gid.nil?
        tube = @world.tube_geometries[gid]
        TubeGeometry.new(tube.circumference, tube.length)
    end

    def surroundings_surface
        host = self.host_object
        host && host.on_surface
    end

    def has_geometry?
        not simple?
    end

    def simple?
        geometry.nil?
    end

    def measure_separation thing1, thing2
        geo = self.geometry
        p1 = thing1.location
        p2 = thing2.location
        meters = geo.distance(p1,p2)
        if meters < 1300
            {:meters => meters, :value => meters.round, :units => 'm'}
        elsif meters < 13000
            {:meters => meters, :value => (meters/1000).round(1), :units => 'km'}
        else
            {:meters => meters, :value => (meters/1000).round, :units => 'km'}
        end
    end

    def temperature
        @surfaces.get(:temperature, @id)
    end

    def set_temperature value
        @surfaces.set(:temperature, @id, value)
    end

    def measure_temperature
        self.temperature || self.host_object&.temperature || -270.0
    end

    def cold?
        self.measure_temperature < 0.0
    end

    def hot?
        self.measure_temperature > 50.0
    end

    def format_temperature
        t = measure_temperature
        if t < 0.0
            "\e[96m#{t.round}°C\e[0m"
        elsif t >= 50.0
            "\e[91m#{t.round}°C\e[0m"
        else
            "#{t.round}°C"
        end
    end

end

