info()    { printf "\\e[32m[INFO]\\e[0m    %s\\n" "$*" >&2 ; }
warning() { printf "\\e[33m[WARNING]\\e[0m %s\\n" "$*" >&2 ; }
error()   { printf "\\e[31m[ERROR]\\e[0m   %s\\n" "$*" >&2 ; }
fatal()   { printf "\\e[35m[FATAL]\\e[0m   %s\\n" "$*" >&2 ; exit 1 ; }
