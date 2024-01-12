function error_msg {
  if [[ ! -z "$1" ]]; then
    echo "[ERROR] $1"
  fi
  echo "\n   $0 [Markdown file]\n"
  exit 1
}

# Help page
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  error_msg ""
fi

# Checks if there's more or less than one argument
if [[ $# -ne 1 ]]; then
  error_msg "Too much arguments or no argument was provided. Use:"
fi

# Check if the file exists
if [[ ! -e "$1" ]]; then
  error_msg "The given file doesn't exist"
fi

# Checks if the given file has the .md extension
if [[ "$1" != *.md ]]; then
  error_msg "The file given is not a Markdown file"
fi

# Conversion
FOLDER_SCRIPT=$(dirname "$0")
FOLDER_MARKDOWN=$(dirname "$1")
FILE_MARKDOWN=$(basename "$1")
FILE_MARKDOWN=${FILE_MARKDOWN%.*}
OUTPUT_FILE="$FILE_MARKDOWN.html"
OUTPUT_FOLDER="$FOLDER_MARKDOWN"

# Create the folder if it doesn't exist
# I CAN'T CREATE ANOTHER FOLDER BECAUSE THIS BEHAVIOR BREAKS THE LINKS INSIDE
# THE MARKDOWN FILE
#
# OUTPUT_FOLDER="$FOLDER_MARKDOWN/$FILE_MARKDOWN"
# if [[ ! -e "$OUTPUT_FOLDER" ]]; then
#   mkdir "$OUTPUT_FOLDER/"
#   mkdir "$OUTPUT_FOLDER/css"
#
#   cp "$FOLDER_SCRIPT/github-markdown.css" "$OUTPUT_FOLDER/css/"
#
#   rm "$OUTPUT_FOLDER/index.html"
# fi

if [[ ! -e "$OUTPUT_FOLDER/css" ]]; then
  mkdir "$OUTPUT_FOLDER/css"
  cp "$FOLDER_SCRIPT/github-markdown.css" "$OUTPUT_FOLDER/css/"
fi

# Create file
  # Deleted pandoc flag: --toc
pandoc --css="./css/github-markdown.css" -s -f markdown+smart --metadata pagetitle="$FILE_MARKDOWN" --to=html5 "$1" | \
sed 's/<body>/<body class="markdown-body">/' \
> "$OUTPUT_FOLDER/$OUTPUT_FILE"

# Indenting headings by putting divs inside the content of every header
nvim "$OUTPUT_FOLDER/$OUTPUT_FILE" -c '%s/<h\([1-6]\)\(\(.*\n\)\{-}\)\ze\(<\/\?h\)/<div class="h\1">\r<h\1\2<\/div>\r/g' -c ':wq'

# Open the output file
xdg-open "$OUTPUT_FOLDER/$OUTPUT_FILE"
