# fenv

## Installation

### Homebrew

```sh
brew tap seokminhong/brew
brew install fenv
# Or
brew install seokminhong/brew/fenv
```

### Cargo install

```sh
cargo install seokmin_fenv
```

## Usage

1. Add the script to your config.fish file

   ```fish
   # ~/.config/fish/config.fish
   fenv init | source
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
