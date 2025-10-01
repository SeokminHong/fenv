use clap::{Parser, Subcommand};
use std::fs;
use std::io;
use std::path::{Path, PathBuf};
use std::process::Command;

#[derive(Parser)]
#[command(version, about, long_about = None, display_name = "fenv")]
#[command(propagate_version = true)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Emit the init script
    Init,
    /// Allow a .envrc.fish file to be loaded
    Allow {
        /// Path to .envrc.fish file (default: current directory)
        path: Option<PathBuf>,
    },
    /// Deny a .envrc.fish file from being loaded
    Deny {
        /// Path to .envrc.fish file (default: current directory)
        path: Option<PathBuf>,
    },
}

fn main() {
    let cli = Cli::parse();
    match &cli.command {
        Commands::Init => {
            println!("{}", INIT_STR);
        }
        Commands::Allow { path } => {
            if let Err(e) = handle_allow(path.as_deref()) {
                eprintln!("Error: {}", e);
                std::process::exit(1);
            }
        }
        Commands::Deny { path } => {
            if let Err(e) = handle_deny(path.as_deref()) {
                eprintln!("Error: {}", e);
                std::process::exit(1);
            }
        }
    }
}

fn get_envrc_path(path: Option<&Path>) -> io::Result<PathBuf> {
    let base_path = if let Some(p) = path {
        p.to_path_buf()
    } else {
        std::env::current_dir()?
    };

    let envrc_path = if base_path.is_dir() {
        base_path.join(".envrc.fish")
    } else {
        base_path
    };

    if !envrc_path.exists() {
        return Err(io::Error::new(
            io::ErrorKind::NotFound,
            format!(".envrc.fish not found at {}", envrc_path.display()),
        ));
    }

    envrc_path.canonicalize()
}

fn get_allowlist_path() -> PathBuf {
    let home = std::env::var("HOME").unwrap_or_else(|_| String::from("/tmp"));
    Path::new(&home).join(".config/fenv/allowed")
}

fn compute_hash(path: &Path) -> io::Result<String> {
    let output = Command::new("shasum")
        .arg(path)
        .output()?;

    if !output.status.success() {
        return Err(io::Error::other("Failed to compute hash"));
    }

    let hash = String::from_utf8_lossy(&output.stdout)
        .split_whitespace()
        .next()
        .unwrap_or("")
        .to_string();

    Ok(hash)
}

fn handle_allow(path: Option<&Path>) -> io::Result<()> {
    let envrc_path = get_envrc_path(path)?;
    let hash = compute_hash(&envrc_path)?;
    let allowlist_path = get_allowlist_path();

    // Create parent directory if it doesn't exist
    if let Some(parent) = allowlist_path.parent() {
        fs::create_dir_all(parent)?;
    }

    // Read existing allowlist
    let content = fs::read_to_string(&allowlist_path).unwrap_or_default();
    let entry = format!("{}///{}\n", hash, envrc_path.display());

    // Check if already allowed with same hash
    let mut found_same = false;
    let mut found_different = false;
    
    for line in content.lines() {
        if let Some(file_path) = line.split("///").nth(1) {
            if file_path == envrc_path.to_string_lossy() {
                if line.starts_with(&hash) {
                    found_same = true;
                } else {
                    found_different = true;
                }
                break;
            }
        }
    }

    if found_same {
        println!("fenv: {} is already allowed", envrc_path.display());
        return Ok(());
    }

    // If file exists with different hash, remove old entry first
    let new_content: String = if found_different {
        content
            .lines()
            .filter(|line| {
                !line.split("///")
                    .nth(1)
                    .map(|p| p == envrc_path.to_string_lossy())
                    .unwrap_or(false)
            })
            .map(|line| format!("{}\n", line))
            .collect()
    } else {
        content
    };

    // Append new entry
    let final_content = format!("{}{}", new_content, entry);
    fs::write(&allowlist_path, final_content)?;

    if found_different {
        println!("fenv: updated allowlist for {}", envrc_path.display());
    } else {
        println!("fenv: allowed {}", envrc_path.display());
    }
    Ok(())
}

fn handle_deny(path: Option<&Path>) -> io::Result<()> {
    let envrc_path = get_envrc_path(path)?;
    let allowlist_path = get_allowlist_path();

    if !allowlist_path.exists() {
        println!("fenv: {} is not in the allowlist", envrc_path.display());
        return Ok(());
    }

    // Read existing allowlist
    let content = fs::read_to_string(&allowlist_path)?;
    let new_content: String = content
        .lines()
        .filter(|line| {
            !line.split("///")
                .nth(1)
                .map(|p| p == envrc_path.to_string_lossy())
                .unwrap_or(false)
        })
        .map(|line| format!("{}\n", line))
        .collect();

    // Write back the filtered content
    fs::write(&allowlist_path, new_content)?;

    println!("fenv: denied {}", envrc_path.display());
    Ok(())
}

const INIT_STR: &str = include_str!("../init.fish");
