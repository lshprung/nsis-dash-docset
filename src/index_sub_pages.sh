#!/usr/bin/env sh

# shellcheck source=./lib/create_table
. "$(dirname "$0")"/lib/create_table
# shellcheck source=./lib/insert
. "$(dirname "$0")"/lib/insert

DB_PATH="$1"
shift
CONTENTS="$1"
shift

insert_sub_page() {
	LINK="$1"
	NAME="$(echo "$LINK" | pup -p 'a text{}' | sed 's/\"\"//g' | tr -d \\n)"
	PAGE_PATH="$(echo "$LINK" | pup -p 'a attr{href}')"

	insert "$DB_PATH" "$NAME" "Guide" "$PAGE_PATH"
}

create_table "$DB_PATH"

grep -Eo "<li><a href.*</a></li>" "$CONTENTS" | while read -r line; do
	insert_sub_page "$line"
done
