#!/bin/zsh

gd() {
  local GOTOUNIXDIR="$HOME/.gotounixlinks"
  local num_par=$#

  # Initialize the directory file if it doesn't exist
  if [[ ! -f $GOTOUNIXDIR ]]; then
    print "File does not exist. Creating file: $GOTOUNIXDIR"
    touch $GOTOUNIXDIR
  fi

  # Print all saved paths with line numbers
  print_path() {
    cat -n $GOTOUNIXDIR
  }

  # Check if the provided path is valid
  valid_path() {
    local dir_path=$1
    if [[ -n "$dir_path" ]] && [[ -d "$dir_path" ]]; then
      return 0  # True
    fi
    print "No such file or path: $dir_path"
    return 1
  }

  # Search for a path in the saved file
  search_path() {
    local dir_path=$1
    grep -q -i "$dir_path" $GOTOUNIXDIR
    return $?
  }

  # Add a path to the saved file
  add_path() {
    local to_add description
    
    if [[ $# -eq 0 ]]; then
      to_add=$PWD
    else
      to_add=$1
      shift
      description=$*
    fi

    if search_path "$to_add"; then
      print "$to_add already remembered."
    elif valid_path "$to_add"; then
      print "Adding: $to_add"
      if [[ -n "$description" ]]; then
        print "$to_add $description" >> $GOTOUNIXDIR
      else
        print "$to_add" >> $GOTOUNIXDIR
      fi
    fi
    print_path
  }

  # Go to a saved path
  goto_path() {
    local dir_str=$1
    local dir_path
    
    if search_path "$dir_str"; then
      dir_path=$(grep -m 1 -i "$dir_str" $GOTOUNIXDIR | cut -d" " -f1)
      pushd "$dir_path" || return 1
    else
      print "Path containing '$dir_str' not found."
      return 1
    fi
  }

  # Show help information
  show_help() {
    print "Usage: gd [-a|-g|-l|-h] [PATH|PATTERN|NUMBER]
Examples:
  gd -a /tmp [description]  # Add /tmp to remembered directories with optional description
  gd -a                     # Add current directory to remembered directories
  gd -g pattern             # Go to directory matching pattern
  gd -l                     # List all remembered directories
  gd number                 # Go to directory at line number
  gd pattern                # Go to directory matching pattern
  gd -h                     # Show this help"
  }

  # If no arguments provided, just list paths
  if [[ $num_par -eq 0 ]]; then
    print_path
    return 0
  fi

  # Check if first argument is a number (shortcut to goto line number)
  if [[ $1 =~ ^[0-9]+$ ]]; then
    local line_num=$1
    local dir_path=$(sed -n "${line_num}p" $GOTOUNIXDIR | cut -d" " -f1)
    if [[ -n "$dir_path" ]]; then
      pushd "$dir_path" || return 1
    else
      print "No directory at line $line_num"
      return 1
    fi
    return 0
  fi

  # Process options
  local OPTIND=1
  while getopts ":aglh" OPTION; do
    case ${OPTION} in
      a) 
        shift $((OPTIND-1))
        add_path "$@"
        return 0
        ;;
      g) 
        shift $((OPTIND-1))
        if [[ -z "$1" ]]; then
          print "Error: -g requires a pattern argument"
          return 1
        fi
        goto_path "$1"
        return $?
        ;;
      l) 
        print_path
        return 0
        ;;
      h) 
        show_help
        return 0
        ;;
      \?) 
        print -u2 "Invalid option: -$OPTARG"
        show_help
        return 2
        ;;
    esac
  done
  
  # If we get here without returning, assume the first argument is a pattern to search
  shift $((OPTIND-1))
  if [[ -n "$1" ]]; then
    goto_path "$1"
    return $?
  fi
}
