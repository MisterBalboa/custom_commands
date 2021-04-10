#!/bin/bash

function rm_swaps() {
  git status | grep -e '\.swp'
  echo 'Remove files? y(yes), n(no): '
  read response

  if [[ $response = y ]]; then
    git status | grep -e '\.swp' | xargs rm
    echo 'Files removed'
  elif [[ $response = n ]]; then
    echo 'Files untouched'
  else
    echo 'Command not recognized'
  fi
}

function back_shellcolors() {
  for color in {0..255} ; do
    printf "\e[48;5;%sm  %3s  \e[0m" $color $color

    if [ $((($color + 1) % 6)) == 4 ] ; then
        echo # New line
    fi
  done

  printf "\nUsage:\n"
  printf "\\\e[48;5;{color_code}m{your_text}\n\n"
}

function shellcolors() {
  for color in {0..255} ; do
    printf "\e[38;5;%sm  %3s  \e[0m" $color $color

    if [ $((($color + 1) % 6)) == 4 ] ; then
        echo # New line
    fi
  done

  printf "\nUsage:\n"
  printf "\\\e[38;5;{color_code}m{your_text}\\\e[0m\n\n"
}

function dockerkill() {
  service="$1"
  docker kill $service; docker rm $service; docker rmi "${service}_image"
}

function dockerestart() {
  dockerkill $1
  docker-compose up -d $1
}

function dockerclean() {
  docker stop $(docker ps -a -q)
  docker rm $(docker ps -a -q)

  if [ "$1" = "--all" ];
    then
      docker rmi $(docker images -q)
  fi
}

function dockerpslim {
  grc docker ps -a | awk '{ print $1, $7, $11}' | grcat /usr/local/Cellar/grc/1.11.3_2/share/grc/conf.dockerps
}

function composelist() {
  if test -f "./docker-compose.yml";
    then
      echo "Services:"
      for service in $(cat docker-compose.yml | grep -E '^[ ]{2}[a-z]' --color=never);
        do
          service_name=$(echo "$service" | sed 's/://')
          printf "  - \e[38;5;219m$service_name\e[0m\n"
      done
    else
      echo "No docker-compose.yml file found.."
  fi
}

function fvim() {
  _file=$(fzf)
  _original_full_path=$(pwd)/$_file

  if test -z $_file; then return; fi

  (cd $(dirname $_file); git rev-parse --show-toplevel > /dev/null) 
  if [ $? -eq 0 ];
    then
      git_path=$(cd $(dirname $_file); git rev-parse --show-toplevel)
      cd $git_path
      vim $_original_full_path
    else
      echo "dirname: $_file"
      cd $(dirname $_file)
      vim $_file
  fi
}

function gtrace() {
  git log \
    --pretty=format:"commit: %C(Yellow)%H %Creset %C(Magenta)%ar %Creset" \
    -L $2,:$1 \
    --color=always | grep -E "(commit:|$3)" -A 3

  colored_line="\033[38;5;201m$2\033[0m"
  colored_file="\033[38;5;186m$1\033[0m"
  colored_match="\033[38;5;208m$3\033[0m"

  print "\nSummary\n========="
  printf "\nTracing line $colored_line in git file... $colored_file, match: $colored_match\n"
}


echo 'Added custom commands.'
