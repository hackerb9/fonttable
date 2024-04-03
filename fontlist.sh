#!/bin/bash -e

trap cleanup INT HUP EXIT
cleanup() {
    echo -n $'\e\\'		# Stop sixel graphics
    exit
}
 
declare -g pointsize=20

main() {
    local charset fullname range label prevname

    if [[ $# -eq 0 ]]; then
	set --  $(convert -list font | grep Font: | cut -d: -f2- | sort)
    fi

    for f; do 
	fullname=$(fc-match --format='%{fullname[0]}\n' "$f" | sed 's/ /-/g')
	if [[ "$fullname" =~ Noto.* ]]; then
	    echo "Skipping $f ($fullname)" >&2
	fi
	if [[ "$fullname" == "$prevname" ]]; then continue; fi
	prevname="$fullname"

	charset=$(fc-match --format='%{charset[0]}\n' "$f" | sed 's/-/../g')
	# charset looks like "20..7e a0 16a0 16a2..16a3"
	label=""
	for range in ${charset}; do
	    label+=$(printf $(expandrange "$range"))
	done
	label=$(escapequote "$label")
	printf "%20s" "$fullname "
	echo $label
	convert -font "$fullname" -pointsize $pointsize \
		-size 800x caption:"$label" sixel:-
	echo
    done
}

expandrange() {
    # Given input like "20..7e" output "\U20" "\U21" ... "\U7d" "\U7e"
    local start=${range%..*}
    local stop=${range#*..}
    local i

    if [[ $start == 0 ]]; then
	# Special case for Carlito which defines a glyph for U+0000
	if [[ $stop == 0 ]]; then echo "\U2400"; return; else start=1; fi
    fi
    
    for ((i=16#$start; i<=16#$stop; i++)); do
	printf '\\'; printf 'U%x' $i
    done
}
		

escapequote() {
    # Given a string with ImageMagick would barf on,
    # escape them so all is copacetic.
    sed '
    	 s/%/\\%/g;
	' <<<"$@"
}

case $1 in
    --pointsize|-pointsize|-p) pointsize="$2"
		    shift 2
		    ;;
esac    
echo pointsize is $pointsize

main "$@"
