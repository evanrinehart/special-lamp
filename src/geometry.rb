require 'matrix'

class PlaneGeometry

    def landmarks # -> points
        {:O => Vector[0.0,0.0]}
        {:X => Vector[1.0,0.0]}
        {:Y => Vector[0.0,1.0]}
    end

    # points are represented using a vector equal to point minus O
    # distance is just the length of the difference of vectors
    def distance point2, point1 # -> real
        (point2 - point1).norm
    end

    # direction is the unit speed tangent
    # point2 = motion point1, direction(point2,point1), 1.0
    def direction point2, point1 # -> tangent
        diff = point2 - point1
        if diff.zero? then nil else diff.normalize end
    end

    def make_velocity dir, speed # -> tangent
        speed * dir
    end

    # assumes no boundary will be crossed before delta_t
    def motion point, velocity, delta_t # -> point
        point + velocity * delta_t
    end

    def time_to_boundary point, vel # -> real
        nil
    end

    def tangent_from_compass point, direction
        case direction
        in :n then Vector[0.0, 1.0]
        in :s then Vector[0.0, -1.0]
        in :e then Vector[1.0, 0.0]
        in :w then Vector[-1.0, 0.0]
        else raise 'invalid direction'
        end
    end

    def interpolate point1, point2, factor
        dir = self.direction point2, point1
        return nil if dir.nil?
        dist = self.distance point2, point1
        vel = self.make_velocity dir, dist*factor
        self.motion point1, vel, 1.0
    end

end

class TileGeometry < PlaneGeometry

    def initialize scale=1.0
        @scale = scale.to_f
        @side = @scale
        @perimeter = 4.0 * @side
    end

    def landmarks
        {
            :O => Vector[0.0,0.0],
            :X => @scale * Vector[1.0,0.0],
            :Y => @scale * Vector[0.0,1.0],
            :XY => @scale * Vector[1.0,1.0]
        }
    end

    def time_to_boundary point, vel
        return nil if vel.nil?
        vx = vel[0]
        vy = vel[1]
        times = []
        times.push(point[0] / -vx) if vx < 0
        times.push((@side - point[0]) / vx) if vx > 0
        times.push(point[1] / -vy) if vy < 0
        times.push((@side - point[1]) / vy) if vy > 0
        times.min
    end

    # would match the Y coord of a tube of the same size
    def to_boundary_coord point
        x = point[0]
        y = point[1]
        if y <= x && y <= @side - x
            x
        elsif y <= x && y >= @side - x
            @side + y
        elsif y >= x && y >= @side - x
            3*@side - x
        else
            4*@side - y
        end
    end

    def from_boundary_coord value
        if value <= 0.25 * @perimeter
            Vector[value, 0.0]
        elsif value <= 0.5 * @perimeter
            Vector[@side, value - @side]
        elsif value <= 0.75 * @perimeter
            Vector[3*@side - value, @side]
        else
            Vector[0.0, 4*@side - value]
        end
    end

    def boundary_velocity_for_tube point, vel
        coord = to_boundary_coord(point) / @perimeter
        if coord <= 0.25
            Vector[-vel[1], vel[0]]
        elsif coord <= 0.5
            vel
        elsif coord <= 0.75
            Vector[vel[1], -vel[0]]
        else
            Vector[-vel[0], -vel[1]]
        end
    end

end

class TubeGeometry

    def initialize length=1.0, circumference=4.0
        @circumference = circumference.to_f
        @length = length.to_f
    end

    def landmarks
        a = 0.0
        b = 0.25 * @circumference
        c = 0.5 * @circumference
        d = 0.75 * @circumference
        {
            :O0 => Vector[0.0,a],
            :O1 => Vector[0.0,b],
            :O2 => Vector[0.0,c],
            :O3 => Vector[0.0,d],
            :X0 => Vector[@length,a],
            :X1 => Vector[@length,b],
            :X2 => Vector[@length,c],
            :X3 => Vector[@length,d]
        }
    end

    # points are represented by a vector = point minus O0
    # in the unwrapped tube.
    def distance point2, point1
        delta_xy(point2, point1).norm
    end

    def direction point2, point1
        point1 == point2 ? nil : delta_xy(point2, point1).normalize
    end

    def make_velocity dir, speed
        speed * dir
    end

    def motion point, vel, delta_t
        new_x = point[0] + vel[0] * delta_t
        new_y = point[1] + vel[1] * delta_t
        Vector[new_x, new_y % @circumference]
    end

    def time_to_boundary point, vel
        return nil if vel.nil? || vel[0].zero?
        x = point[0]
        vx = vel[0]
        if vx < 0.0
            x > 0.001 ? x / -vx : 0.0
        else
            standoff = @length - x
            standoff > 0.001 ? standoff / vx : 0.0
        end
    end

    def delta_xy point2, point1
        dx = point2[0] - point1[0]
        dy = delta_y point2[1], point1[1]
        Vector[dx,dy]
    end

    def delta_y y2, y1
        y3 = y2 + @circumference
        y4 = y2 - @circumference
        d1 = y2 - y1
        d2 = y3 - y1
        d3 = y4 - y1
        [d1,d2,d3].min_by{|x| x.abs}
    end

    def tangent_from_compass point, direction
        case direction
        in :n then Vector[0.0, 1.0]
        in :s then Vector[0.0, -1.0]
        in :e then Vector[1.0, 0.0]
        in :w then Vector[-1.0, 0.0]
        else raise 'invalid direction'
        end
    end

    def interpolate point1, point2, factor
        dir = self.direction point2, point1
        return nil if dir.nil?
        dist = self.distance point2, point1
        vel = self.make_velocity dir, dist*factor
        self.motion point1, vel, 1.0
    end

end

class SphereGeometry

    def initialize circumference=4.0
        @circumference = circumference
        @scale = @circumference / 4.0
        @inv_scale = 1.0 / @scale
    end

    def landmarks
        {
            :N => Vector[0.0,1.0],
            :S => Vector[0.0,-1.0],
            :A => Vector[0.0,0.0],
            :B => Vector[1.0,0.0],
            :C => Vector[2.0,0.0],
            :D => Vector[3.0,0.0],
        }
    end

    # points are numbers in [0,4] x [-1,1] regardless of scale
    def distance point2, point1
        v2 = to_vector3 point2
        v1 = to_vector3 point1
        @scale * 2 * Math.acos(v2.dot(v1)) / Math::PI
    end

    def direction point2, point1
        v2 = to_vector3 point2
        v1 = to_vector3 point1
        v3 = v1.cross(v2)
        v3.norm < 0.000001 ? nil : v3.normalize
    end

    def make_velocity dir, speed
        speed * dir
    end

    def motion point, velocity, delta_t
        return point if velocity.nil?
        axis = velocity.normalize
        speed = velocity.norm
        angle = @inv_scale * delta_t * speed * Math::PI / 2.0
        old_v = to_vector3 point
        new_v = rotate_vector(axis, angle, old_v)
        from_vector3 new_v
    end

    def time_to_boundary point, velocity
        nil
    end

    def to_vector3 point
        lon_angle, lat_angle = spherical_coords point
        Vector[
            Math.cos(lat_angle) * Math.sin(lon_angle),
            Math.sin(lat_angle),
            Math.cos(lat_angle) * Math.cos(lon_angle)
        ]
    end

    def from_vector3 some_vec
        v = some_vec.normalize
        x = v[0]
        y = v[1]
        z = v[2]
        lon_angle = Math.atan2(x,z)
        lat_angle = Math.atan2(y,Math.sqrt(x*x + z*z))
        to_point lon_angle, lat_angle
    end

    def spherical_coords point
        lon_angle = point[0] * Math::PI * 2.0 / 4.0
        lat_angle = point[1] * Math::PI / 2.0
        return lon_angle, lat_angle
    end

    def to_point lon_angle, lat_angle
        Vector[
            4.0 * lon_angle / (2.0 * Math::PI),
            2.0 * lat_angle / Math::PI
        ]
    end

    # Rodrigues' rotation formula
    # v′ = v cos θ + (k×v) sin θ + k (k dot v)(1−cos θ)
    def rotate_vector(axis, angle, v)
        axis = axis.normalize

        c = Math.cos(angle)
        s = Math.sin(angle)

        v * c +
            axis.cross(v) * s +
                axis * (axis.dot(v) * (1 - c))
    end

    def tangent_from_compass point, direction
        lon_angle = point[0]
        case direction
        in :e then Vector[0.0, 1.0, 0.0]
        in :w then Vector[0.0, -1.0, 0.0]
        in :n then rotate_vector(Vector[0.0,1.0,0.0], lon_angle, Vector[-1.0, 0.0, 0.0])
        in :s then rotate_vector(Vector[0.0,1.0,0.0], lon_angle, Vector[1.0, 0.0, 0.0])
        else raise 'invalid direction'
        end
    end

    def interpolate point1, point2, factor
        axis = self.direction point2, point1
        return nil if axis.nil?
        v1 = to_vector3 point1
        v2 = to_vector3 point2
        angle = Math.acos(v2.dot(v1))
        v3 = rotate_vector(axis, angle*factor, v1)
        from_vector3 v3
    end

end
