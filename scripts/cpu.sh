#!/usr/bin/env bash

set noglob

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/helpers.sh"

# Colors
usage_format_begin_danger=$(get_tmux_option "@usage_format_begin_danger" "#[fg=black,bg=red]")
usage_format_begin_warning=$(get_tmux_option "@usage_format_begin_warning" "#[fg=black,bg=yellow]")
usage_format_end=$(get_tmux_option "@usage_format_end" "#[fg=default,bg=default]")

# Icon
usage_icon_cpu=$(get_tmux_option "@usage_icon_cpu" " CPU ")

# Thresholds
usage_threshold_cpu_danger=$(get_tmux_option "@usage_threshold_cpu_danger" "90")
usage_threshold_cpu_warning=$(get_tmux_option "@usage_threshold_cpu_warning" "80")

main() {
  local output
  local cores
  local real_load_average

  # Get number of cores
  cores=$(egrep -e "core id" -e ^physical /proc/cpuinfo|xargs -l2 echo|sort -u | wc -l)

  # Calculate 1m load average/core
  # https://github.com/riemann/riemann-tools/blob/master/bin/riemann-health
  real_load_average=$(cat /proc/loadavg | awk -v cores=${cores} '{printf "%.0f", $1 * 100 / cores}')

  # Test against thresholds.
  if [ "$real_load_average" -ge "$usage_threshold_cpu_danger" ]; then
    output=" $usage_format_begin_danger$usage_icon_cpu$usage_format_end"
  elif [ "$real_load_average" -ge "$usage_threshold_cpu_warning" ]; then
    output=" $usage_format_begin_warning$usage_icon_cpu$usage_format_end"
  else
    output=""
  fi

  echo "$output"
}

main
