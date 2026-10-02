def parse_value(string)
    if /\A-?\d+\z/ =~ string
        Integer(string)
    elsif /\A-?\d+.\d+\z/ =~ string
        Float(string)
    elsif /\A:[A-Za-z_][A-Za-z0-9_]*\z/ =~ string
        string[1..].to_sym
    elsif /\Anil\z/ =~ string
        nil
    elsif /\Atrue\z/ =~ string
        true
    elsif /\Afalse\z/ =~ string
        false
    else
        string
    end
end

def take_quoted(whole_line)
    rest = whole_line.chars
    rest.shift => '"'
    output = []
    loop do
        c = rest.shift
        break if c.nil?
        if c == '\\'
            if rest[0] == '\\'
                rest.shift
                output.push '\\'
            elsif rest[0] == '"'
                rest.shift
                output.push '"'
            elsif rest[0] == 'n'
                rest.shift
                output.push "\n"
            else
                # keep next char
                output.push '\\'
            end
        elsif c == '"'
            break
        else
            output.push c
        end
    end
    return output.join(''), rest.join('')
end

def tokenize(string)
    tokens = []
    string.lstrip!
    loop do
        break if string.empty?
        if string[0] == '"'
            piece, rest = take_quoted(string)
        else
            piece, _, rest = string.partition(/ /)
        end
        tokens.push piece
        string = rest.lstrip
    end
    tokens
end
