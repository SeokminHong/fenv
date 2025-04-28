# fenv

## Installation

### Homebrew

```sh
brew tap seokminhong/homebrew
brew install fenv
```

## Manual

```sh
git clone https://github.com/SeokminHong/fenv.git
```

## Usage

1. Add the script to your config.fish file

   ```fish
   # ~/.config/fish/config.fish
   source fenv-cloned-path/fenv.fish
   ```

2. Write `.envrc.fish` file to your directory and declare `fenv_load` and `fenv_unload` functions

   ```fish
   # ~/foo/bar/.envrc.fish
   function fenv_load
     set -gx my_var "Hello!"
   end

   function fenv_unload
     set -e my_var
   end
   ```

## Demo

https://github.com/user-attachments/assets/2f0429b7-99b7-4566-81cd-20a582abefe5
