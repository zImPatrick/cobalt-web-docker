set -e

# BusyBox doesn't like *.html and prefers */index.html
for file in $(find . -name '*.html' ! -name 'index.html'); do
  path=$(echo $file | sed 's/\.html$//')

  if [ ! -d "$path" ]; then
    mkdir $path
  fi

  mv $file $path/index.html
done
