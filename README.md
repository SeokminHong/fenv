# fenv

## Usage

1. Clone this repository
2. Add the script to your config.fish file

   ```fish
   # ~/.config/fish/config.fish
   source fenv-cloned-path/fenv.fish
   ```

3. Write `.envrc.fish` file to your directory and declare `__fenv_load` and `__fenv_unload` functions

   ```fish
   # ~/foo/bar/.envrc.fish
   function __fenv_load
     set -gx my_var "Hello!"
   end

   function __fenv_unload
     set -e my_var
   end
   ```
