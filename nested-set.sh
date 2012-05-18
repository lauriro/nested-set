#!/bin/sh
#
#-
#- Nested set model example
#- ========================
#-
#
# THE BEER-WARE LICENSE
# =====================
#
# <lauri@rooden.ee> wrote this file. As long as you retain this notice
# you can do whatever you want with this stuff. If we meet some day, and
# you think this stuff is worth it, you can buy me a beer in return.
# -- Lauri Rooden
#


DB="sqlite3 ${0%.*}.db"


# Exit the script if any statement returns a non-true return value
set -e


usage() {
	sed -n "/^#- \?/s///p" "$0" >&2
}


tree_print() {
	$DB "SELECT id, parent, lft, rgt, name FROM tree $1 ORDER BY lft ASC" | {
		local S=""     # Stack of RGT's
		local P=""     # Prefix string for drawing tree

		while IFS=\| read ID PAR LFT RGT NAME; do

			while [ ${#S} -gt 0 ] && [ ${S%% *} -lt $RGT ]; do 
				S="${S#* }"
				P="${P%???}"
			done
			P="$P  |"

			printf "%3s[%3s] %3s-%-3s   %s\n" $ID $PAR $LFT $RGT "$P- $NAME"

			# When node is last under it's parent
			if [ ${#S} -eq 0 ] || [ $((${S%% *}-1)) -eq $RGT ]; then
				P="${P%?} "
			fi

			S="$RGT $S"
		done
	}
}


tree_resize() {
	[ $2 -gt 0 ] && $DB "UPDATE tree SET rgt=rgt+$2 WHERE rgt>=$1 AND lft<rgt"
	$DB "UPDATE tree SET lft=lft+($2) WHERE lft>$1 AND lft<rgt"
	[ $2 -lt 0 ] && $DB "UPDATE tree SET rgt=rgt+($2) WHERE rgt>$1 AND lft<rgt"
	return 0
}


tree_rebuild() {
	$DB "SELECT id FROM tree WHERE parent=$1 ORDER BY lft" | {
		local RGT=$(($2+1))

		while read ID; do
			RGT=$(tree_rebuild $ID $RGT)
		done

		$DB "UPDATE tree set lft=$2, rgt=$RGT WHERE id=$1"
		echo $(($RGT+1))
	}
}



#- Commands are:
#-   init                          Create database
#-   add <parent_id> <name>        Add node to end
#-   addFirst <parent_id> <name>   Add node to beginning
#-   del <node_id>                 Remove node with childs
#-   delOne <node_id>              Remove only node and move childs under parent
#-   move <node_id> <parent_id>    Move node under new parent
#-   swap <node_id> <node_id>      Swap two node with childs
#-   order <node_id> <child_ids>   Sort childs
#-   path <node_id>                Print path
#-   childs <node_id>              Print childs
#-   leafs                         Print leafs
#-   rebuild                       Rebuild left and right indexes
#-   reset                         Delete database and init again


case $1 in
	init)
		$DB < "${0%.*}.sql"
		tree_print
		;;
	add|addLast)
		RGT=$($DB "SELECT rgt FROM tree WHERE id=$2")
		tree_resize $RGT 2
		$DB "INSERT INTO tree (parent, lft, rgt, name) VALUES ($2, $RGT, $RGT+1, '$3')"
		tree_print
		;;
	addFirst)
		LFT=$($DB "SELECT lft FROM tree WHERE id=$2")
		tree_resize $LFT 2
		$DB "INSERT INTO tree (parent, lft, rgt, name) VALUES ($2, $LFT+1, $LFT+2, '$3')"
		tree_print
		;;
	del)
		$DB "SELECT lft, rgt, rgt-lft+1 FROM tree WHERE id=$2" | {
			IFS=\| read LFT RGT LEN

			$DB "DELETE FROM tree WHERE lft>=$LFT AND lft<$RGT"
			tree_resize $RGT -$LEN
		}
		tree_print
		;;
	delOne)
		$DB "SELECT lft, rgt, parent FROM tree WHERE id=$2" | {
			IFS=\| read LFT RGT PAR

			$DB "DELETE FROM tree WHERE lft=$LFT"
			$DB "UPDATE tree SET lft=lft-1, rgt=rgt-1 WHERE lft>$LFT AND lft<$RGT"
			tree_resize $RGT -2
			$DB "UPDATE tree SET parent=$PAR WHERE parent=$2"
		}
		tree_print
		;;
	move)
		$DB "SELECT lft, rgt, rgt-lft+1 FROM tree WHERE id=$2" | {
			IFS=\| read LFT RGT LEN

			NEW_RGT=$($DB "SELECT rgt FROM tree WHERE id=$3")
			if [ $NEW_RGT -ge $LFT -a $NEW_RGT -le $RGT ]; then
				echo "Illegal move"
				exit 1
			fi
			# Mark moved nodes, later we do not touch where lft>rgt
			$DB "UPDATE tree SET lft=lft+rgt WHERE lft>=$LFT AND lft<$RGT"

			# Make a new hole for marked nodes
			tree_resize $NEW_RGT $LEN

			# Close old hole
			tree_resize $RGT -$LEN

			# Find diff between old and new hole
			DIFF=$($DB "SELECT $RGT-rgt+1 FROM tree WHERE id=$3")

			# Move marked nodes into new positions
			$DB "UPDATE tree SET lft=lft-rgt-($DIFF), rgt=rgt-($DIFF) WHERE lft>rgt"
			$DB "UPDATE tree SET parent=$3 WHERE id=$2"
		}
		tree_print
		;;
	swap)
		$DB "SELECT id, lft, rgt, parent, rgt-lft+1 FROM tree WHERE id IN ($2, $3) ORDER BY lft" | {
			IFS=\| read ID_A LFT_A RGT_A PAR_A LEN_A
			IFS=\| read ID_B LFT_B RGT_B PAR_B LEN_B

			if [ $LFT_B -ge $LFT_A -a $LFT_B -le $RGT_A ]; then
				echo "Illegal swap"
				exit 1
			fi

			# Update parents when needed
			if [ $PAR_A -ne $PAR_B ]; then
				$DB "UPDATE tree SET parent=$PAR_B WHERE id=$ID_A"
				$DB "UPDATE tree SET parent=$PAR_A WHERE id=$ID_B"
			fi

			# Mark moved nodes, later we do not touch where lft>rgt
			$DB "UPDATE tree SET lft=lft+rgt WHERE lft>=$LFT_A AND lft<$RGT_A"
			$DB "UPDATE tree SET lft=lft+rgt WHERE lft>=$LFT_B AND lft<$RGT_B AND lft<rgt"

			LEN_DIFF=$(($LEN_B-$LEN_A))
			# Resize holes when needed
			if [ $LEN_DIFF -ne 0 ]; then
				tree_resize $RGT_B $((0-$LEN_DIFF))
				tree_resize $RGT_A $LEN_DIFF
			fi

			# Move marked nodes into new positions
			LFT_DIFF=$(($LFT_B-$LFT_A))
			$DB "UPDATE tree SET lft=lft-rgt-$LFT_DIFF, rgt=rgt-$LFT_DIFF WHERE lft>rgt AND rgt>$LFT_B AND rgt<=$RGT_B"

			LFT_DIFF=$(($LFT_DIFF+$LEN_DIFF))
			$DB "UPDATE tree SET lft=lft-rgt+$LFT_DIFF, rgt=rgt+$LFT_DIFF WHERE lft>rgt"
		}

		tree_print
		;;
	order)
		$DB "SELECT id FROM tree WHERE parent=$2 ORDER BY lft ASC" | {
			DIFF=""
			ARR="$3,"
			while read ID; do
				test "${ARR%%,*}" -ne "$ID" && DIFF="$DIFF $ID"
				ARR="${ARR#*,} ${ARR%%,*}"
			done
			if [ ${#DIFF} -eq 0 ]; then
				echo "Nothing changed"
			# FIXME: $DIFF lenght does not show nember of nodes
			#elif [ ${#DIFF} -eq 2 ]; then
			#	echo "Swap $DIFF"
			#	$0 swap "${DIFF% *}" "${DIFF#* }"
			else
				POS=0
				echo "Sort with rebuild"
				for ID in $ARR; do
					$DB "UPDATE tree SET lft=$POS WHERE id=$ID AND parent=$2"
					POS=$(($POS+1))
				done
				tree_rebuild $2 $($DB "SELECT lft FROM tree WHERE id=$2") >/dev/null
				tree_print
			fi
		}
		;;
	path)
		RGT=$($DB "SELECT lft, rgt FROM tree WHERE id=$2")
		LFT=${RGT%%|*} && RGT=${RGT#*|}
		# NOTE: remove '=' from SQL to remove self
		tree_print "WHERE lft<=$LFT AND rgt>=$RGT"
		;;
	childs)
		RGT=$($DB "SELECT lft, rgt FROM tree WHERE id=$2")
		LFT=${RGT%%|*} && RGT=${RGT#*|}
		# NOTE: remove '=' from SQL to remove self
		tree_print "WHERE lft>=$LFT AND lft<$RGT"
		;;
	leafs)
		tree_print "WHERE 1=rgt-lft"
		;;
	print)
		tree_print
		;;
	rebuild)
		tree_rebuild 0 0 >/dev/null
		tree_print
		;;
	reset)
		rm "${0%.*}.db"
		$0 init
		;;
	*)
		usage
		;;
esac


