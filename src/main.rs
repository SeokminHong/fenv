use clap::{Parser, Subcommand};

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
}

fn main() {
    let cli = Cli::parse();
    match &cli.command {
        Commands::Init => {
            println!("{}", INIT_STR);
        }
    }
}

const INIT_STR: &str = include_str!("../init.fish");
