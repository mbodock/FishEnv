#!/usr/bin/fish
function mkvirtualenv -d 'Create virtualenv on the current directory'
    if test -z (cat $HOME/.fishenvs/envs | egrep -i "^$argv[1]\$" | head -n 1)
        set dir (pwd)
        mkdir -p "$HOME/.fishenvs/"
        cd "$HOME/.fishenvs/"

        if test (count $argv) -ge 2
            virtualenv $argv[1] $argv[2..-1]
        else
            virtualenv $argv[1]
        end
        echo "$argv[1] $dir" >> ~/.fishenvs/envs
        cd $dir
    else
        set_color F00
        echo "Env with this alias already exists"
        set_color normal
    end
end

function mktmpenv -d 'Creates a temporary virtualenv'
    set dir (pwd)
    mkdir -p "/tmp/fishtmpenvs"
    cd  "/tmp/fishtmpenvs"

    if test -n $argv[1]
        set -g -x ENV_NAME "$argv[1]"
    else
        set -g -x ENV_NAME (cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 6 | head -n 1)
    end
    echo "Creating $ENV_NAME..."
    virtualenv $ENV_NAME $argv[2..-1]
    cd $ENV_NAME
    . ./bin/activate.fish
    function deactivate -d "Exits and deletes virtualenv"
        _original_deactivate
        echo "removing files /tmp/fishtmpenvs/$ENV_NAME"
        rm -rf "/tmp/fishtmpenvs/$ENV_NAME"
        set -e ENV_NAME
    end
    cd $dir
end


function _original_deactivate  -d "Exit virtualenv and return to normal shell environment"
    # reset old environment variables
    if test -n "$_OLD_VIRTUAL_PATH"
        set -gx PATH $_OLD_VIRTUAL_PATH
        set -e _OLD_VIRTUAL_PATH
    end
    if test -n "$_OLD_VIRTUAL_PYTHONHOME"
        set -gx PYTHONHOME $_OLD_VIRTUAL_PYTHONHOME
        set -e _OLD_VIRTUAL_PYTHONHOME
    end

    if test -n "$_OLD_FISH_PROMPT_OVERRIDE"
        # set an empty local fish_function_path, so fish_prompt doesn't automatically reload
        set -l fish_function_path
        # erase the virtualenv's fish_prompt function, and restore the original
        functions -e fish_prompt
        functions -c _old_fish_prompt fish_prompt
        functions -e _old_fish_prompt
        set -e _OLD_FISH_PROMPT_OVERRIDE
    end

    set -e VIRTUAL_ENV
    if test "$argv[1]" != "nondestructive"
        # Self destruct!
        functions -e deactivate
    end
end

function rmvirtualenv -d 'Removes <name> virtualenv'
    set -l envs (cat $HOME/.fishenvs/envs | grep -i "^$argv[1] "|cut -d' ' -f1 )
    set -l matchs (echo $envs| wc -w)
    if [ $matchs = '1' ]
        cat $HOME/.fishenvs/envs | egrep -v -i "^$argv[1] " > /tmp/pivot.tmp
        cat /tmp/pivot.tmp > $HOME/.fishenvs/envs
        rm /tmp/pivot.tmp
        rm -rf "$HOME/.fishenvs/$argv[1]"
        echo "VirtualEnv removed: "$envs
    else if [ $matchs = '2' ]
        set_color F00
        echo 'Multiples Envs found.'
        set_color normal
        echo $envs | xargs
    else
        echo "VirtualEnv not found."
    end
end

function workon -d 'Loads $arg env and cd in to env\'s folder'
    . $HOME/.fishenvs/$argv[1]/bin/activate.fish
    set -U fishenv $argv[1]
    cd (get_env_dir $argv[1])
end

function get_env_dir
    echo (cat "$HOME/.fishenvs/envs" | egrep "^$argv[1]" | cut -d' ' -f2- | head -n 1)
end

function workon_dir -d 'Changes the directory of the working env or $arg env'
    if test -z $fishenv
        set -U fishenv $argv[1]
    end
    set dir (pwd)
    cat "$HOME/.fishenvs/envs" | egrep -v "^$fishenv" > $HOME/.fishenvs/envs
    echo "$fishenv $dir" >> ~/.fishenvs/envs
end

function __fish_fishenv_using_command
    set opts (commandline -opc)
    if [ (count $opts) = 1 ]
        return 0
    end
    return 1
end

complete -c workon -f -n "__fish_fishenv_using_command" -a "(cat "$HOME/.fishenvs/envs" | cut -d' ' -f1 )" -d "Virtual Env"
