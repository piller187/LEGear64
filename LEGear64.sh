export LD_LIBRARY_PATH=".:${LD_LIBRARY_PATH}"
exec "./$PROJECT_NAME" "$@"
