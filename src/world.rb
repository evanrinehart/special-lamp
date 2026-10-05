# ClassData is a table with defined columns and zero or more entries
# SomeWorld is a collection of ClassData tables

require 'pstore'

class ClassData

    attr_reader :name, :idlist

    def initialize(name, idlist=Set[], columns={}, defaults={})
        @name = name
        @idlist = idlist
        @columns = columns
        @defaults = defaults
    end

    def props
        @columns.keys
    end

    def default_for prop
        @defaults[prop]
    end

    def exists? id
        @idlist.include? id
    end

    def has_prop? name
        @columns.keys.include? name
    end

    def population
        @idlist.count
    end

    def get_column(prop)
        @columns[prop]
    end

    def [](id)
        RowProxy.new(self, id)
    end

    def first
        id = @idlist.first
        id && self[id]
    end

    def get(prop, id)
        column = @columns.fetch(prop) do
            raise "#{@name} doesn't have prop #{prop}"
        end
        column.fetch(id) do
            @defaults[prop]
        end
    end

    def set(prop, id, value)
        column = @columns.fetch(prop) do
            raise "#{@name} doesn't have prop #{prop}"
        end
        if exists? id
            if value == default_for(prop)
                column.delete id
            else
                column[id] = value
            end
        else
            raise "#{@name} id=#{id} doesn't exist"
        end
    end

    def insert(id, fields)
        if @idlist.include? id
            raise "#{@name} id=#{id} already exists"
        else
            update(id, fields)
        end
    end

    def update(id, fields)
        keys1 = @columns.keys.to_set
        keys2 = fields.keys.to_set
        diff = keys2.subtract keys1
        if diff.empty?
            @idlist.add id
            fields.each do |k,v|
                @columns[k][id] = v
            end
        else
            raise "unknown field(s) #{diff.to_a}"
        end
    end

    def delete(id)
        @idlist.delete id
        @columns.each do |prop, column|
            column.delete id
        end
    end

    def find_by(prop, a)
        results = []
        @columns[prop].each do |id,b|
            results.push RowProxy.new(self,id) if a==b
        end
        results
    end

    def find_first_by(prop, a)
        @columns[prop].each do |id,b|
            return RowProxy.new(self,id) if a==b
        end
        nil
    end

    def add_prop(prop, value)
        if @columns.keys.include? prop
            nil
        else
            @columns[prop] = {}
            @defaults[prop] = value
        end
    end

    def delete_prop!(prop)
        @columns.delete prop
        @defaults.delete prop
    end

    def to_table
        rows = []
        heading = []
        heading.push @name
        props = @columns.keys
        props.each do |k|
            heading.push k
        end
        rows.push heading
        @idlist.each do |id|
            row = [id]
            props.each do |k|
                row.push get(k,id)
            end
            rows.push row
        end
        rows
    end

    def to_table_text
        rows = []
        heading = []
        heading.push @name.to_s
        props = @columns.keys
        props.each do |k|
            heading.push k.to_s
        end
        rows.push heading
        @idlist.each do |id|
            row = [id.to_s]
            props.each do |k|
                value = get(k,id)
                row.push(value.is_a?(String) ? value : value.inspect)
            end
            rows.push row
        end
        rows
    end

    def to_rows
        @idlist.map do |id|
            RowProxy.new(self,id).to_h
        end
    end

    def dump
        table = self.to_table_text
        widths = table.transpose.map{|col| col.map{|x| x.length}.max }
        table.each do |row|
            elems = row.each_with_index.map { |value, i| value.ljust(widths[i]) }
            puts elems.join("  ")
        end
    end

    def reorder prop
        if @columns.keys.include? prop
            col = @columns.delete prop
            @columns[prop] = col
        else
            raise "no such property"
        end
    end

end


class RowProxy

    def initialize(table, id)
        @table = table
        @id = id
    end

    def id
        @id
    end

    def method_missing(m)
        @table.get(m, @id)
    end

    def update(fields)
        @table.update(@id, fields)
    end

    def to_h
        h = {:id => @id}
        @table.props.each do |k|
            h[k] = @table.get(k, @id)
        end
        h
    end

    def inspect
        @table.name.to_s.capitalize + "Proxy" + self.to_h.inspect
    end

end

def load_world(filename)
    return nil unless File.exist?(filename)
    store = PStore.new(filename)
    store.transaction(true) do
        tables = {}
        store.keys.each do |name|
            tables[name] = store[name]
        end
        SomeWorld.new(tables)
    end
end

def load_schema(filename)
    file = File.new(filename)
    world = SomeWorld.new
    file.readlines(:chomp => true).each do |line|
        arg0, arg1, arg2 = tokenize(line)
        k = arg0.to_sym
        p = arg1.to_sym
        d = parse_value(arg2)
        world.add_empty_class k if world[k].nil?
        world[k].add_prop(p,d)
    end
    file.close
    world
end

class SomeWorld
    def initialize(tables={})
        @tables = {}
        tables.each do |name,table|
            add_class(table)
        end

        i = compute_max_id
        @id_gen = i + 1
    end

    def [](name)
        @tables[name]
    end

    def all(name)
        @tables[name].idlist
    end

    def save_world(filename)
        store = PStore.new(filename)
        store.transaction do
            store.keys.each do |name|
                store.delete name
            end
            @tables.each do |name, table|
                store[name] = table
            end
        end
    end

    def add_class(table)
        if @tables.keys.include? table.name
            raise "table already exists"
        end

        name = table.name
        @tables[name] = table
        define_singleton_method(name) do
            @tables[name]
        end
    end

    def add_empty_class(name)
        add_class(ClassData.new(name))
    end

    def delete_class(name)
        if @tables.keys.include? name
            @tables.delete name
        else
            raise "table #{name} not found"
        end
    end

    def is_valid?
        true
    end

    def dump
        @tables.each do |name, table|
            table.dump
            puts ""
        end
    end

    def dump_text io=$stdout
        @tables.each do |class_name,table|
            io.puts "addclass #{class_name}"
        end
        @tables.each do |class_name,table|
            table.props.each do |prop|
                default = table.default_for prop
                io.puts "addprop #{class_name} #{prop} #{default.inspect}"
            end
        end
        @tables.each do |class_name,table|
            table.idlist.each do |id|
                io.puts "spawnid #{class_name} #{id}"
            end
        end
        @tables.each do |class_name,table|
            table.props.each do |prop|
                default = table.default_for prop
                table.idlist.each do |id|
                    v = table.get(prop, id)
                    if v != default
                        io.puts "set #{class_name} #{id} #{prop} #{v.inspect}"
                    end
                end
            end
        end
    end


    def dump_schema
        @tables.each do |name,table|
            table.props.each do |prop|
                d = table.default_for(prop)
                puts "#{name} #{prop} #{d.inspect}"
            end
        end
    end


    def compute_max_id
        i = 0
        @tables.each do |name, table|
            n = table.idlist.max
            i = n > i ? n : i unless n.nil?
        end
        i
    end

    def generate_id
        n = @id_gen
        @id_gen += 1
        n
    end

    def reorder klass, prop
        table = @tables[klass]
        if table.nil?
            raise "no such class"
        else
            table.reorder prop
        end
    end

end
