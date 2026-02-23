FLOW_DEFAULTS=("envsetup" "resources" "archives" "Makefile" "git" "scripts" "test.sh")

{ 
find . -maxdepth 1 -type d | sed 's/^\.\///g' | grep -v '^\.$' | grep -v '^\.\.$'
find . -maxdepth 1 -type f | sed 's/^\.\///g'; 
find . -maxdepth 1 \( -type f -o -type l \) | sed 's/^\.\///g'
} | grep -v -F -f <(printf "%s\n" "${FLOW_DEFAULTS[@]}") | xargs rm -rf 

