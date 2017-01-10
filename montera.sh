#!/bin/bash

command_opening_tag="{{"
command_terminating_tag="}}"

temporary_file_name_prefix="tempyTemp"$(date +%s)

# Takes a single string message and will output it in red before exiting the execution.
function error {
    local red="\033[0;31m"
    local clear="\033[0m"

    echo -e "${red}$1${clear}"
    exit
}

# Takes a single string messages and will output it in green.
function success {
    local green="\033[0;32m"
    local clear="\033[0m"

    echo -e "${green}$1${clear}"
}

# Will output the temporary filename generated for the provided file.
function get_temp_file_name_for_file {
    echo $temporary_file_name_prefix$(basename $1)$(echo $(realpath $1) | md5sum | awk '{print $1}')
}

# Extracts commands from the provided file and passes them off to be processed.
function extract_commands_from_file {

    # Get the full file path for the provided file.
    local file_path=$(realpath $1)

    # Create a temporary file name for the provided file.
    local temp_file=$(get_temp_file_name_for_file $file_path)

    # Don't bother creating the temporary file again if it already exists as it will be fully processed.
    if [ -f $temp_file ]; then
        return
    fi

    success "Building  "$file_path

    # Copy the contents of the provided file into a temporary equivalent.
    $(cat $file_path > $temp_file)

    # Initialise variables to keep track of the command being built.
    local command_parts=()
    local command_part_index=0

     for command_fragment in $(grep -o -P '{{\s+([a-z]+)\s+.*\s+}}' $temp_file); do

        if [ $command_fragment = $command_opening_tag ]; then
            continue # Skip the opening tag of a command.
        elif [ $command_fragment = $command_terminating_tag ]; then
            # Pass the current file path along with all parts of the command for further processing.
            process_command $file_path ${command_parts[@]}

            # Reset
            command_parts=()
            command_part_index=0
        else # Handle the keywords and parameters within a command
            # Add the current fragment to the command parts array
            command_parts+=($command_fragment)
            # Increment the command part index.
            ((command_part_index++))
        fi

    done
}

# Delegates commands to the appropriate functions.
# The first parameter is the file calling the command.
# The second parameter is the name of the command
# Subsequent parameters are arguments for this command
function process_command {
    local calling_file=$1
    local command=$2

    if [ $command = "include" ]; then
        process_include_command $calling_file $3
    else
        error "Unrecognised command keyword '"$command"'"
    fi
}

# Processes and include command for a file.
# The first parameter is the file calling the include command
# The second parameter is the file to include.
function process_include_command {

    local calling_file=$1
    local calling_file_temp=$(get_temp_file_name_for_file $calling_file)
    local file_to_include=$2
    local file_to_include_path=$(dirname $calling_file)"/"$file_to_include

    success "Including "$file_to_include_path

    extract_commands_from_file $file_to_include_path

    local replace_this="{{ include $file_to_include }}" # This isn't reliable
    local with_this=$(cat $(get_temp_file_name_for_file $file_to_include_path))
    local content=$(cat $calling_file_temp)

    echo "${content//$replace_this/$with_this}" > $calling_file_temp
}

# Will remove all of the temporary files that have been created.
# TODO move these to the tmp directory.
function clean_up_temporary_files {
    rm $temporary_file_name_prefix*
}
########################################################################################################################

input_file=$1
output_file=$2

if [ ! -e $input_file ]; then
    error "Input file '"$input_file"' does not exist."
elif [ ! -f $1 ]; then
    error "Input file '"$input_file"' is not a regular file."
elif [ ! -r $1 ]; then
    error "Input file '"$input_file"' is not readable."
fi

if [ -e $output_file ]; then
    if [ ! -f $output_file ]; then
        error "Output file '"$output_file"' is not a regular file."
    elif [ ! -w $output_file ]; then
        error "Output file '"$output_file"' is not writable."
    fi
fi

extract_commands_from_file $input_file

echo "Outputting to "$output_file
$(cat $(get_temp_file_name_for_file $input_file) > $output_file)

clean_up_temporary_files