function mkcd --description 'mkdir -p a directory and cd into it'
    if test (count $argv) -ne 1
        echo "usage: mkcd <dir>" >&2
        return 1
    end
    mkdir -p -- $argv[1]; and cd -- $argv[1]
end
