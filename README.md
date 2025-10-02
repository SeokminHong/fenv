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

3. Allow the `.envrc.fish` file to be loaded

   Similar to direnv, fenv requires you to explicitly allow `.envrc.fish` files before they are loaded. This is a security feature to prevent untrusted code from automatically executing.

   ```sh
   # In the directory containing .envrc.fish
   fenv allow

   # Or specify the path
   fenv allow /path/to/.envrc.fish
   ```

   To revoke access:

   ```sh
   # In the directory containing .envrc.fish
   fenv deny

   # Or specify the path
   fenv deny /path/to/.envrc.fish
   ```

## Demo

https://github.com/user-attachments/assets/2f0429b7-99b7-4566-81cd-20a582abefe5
