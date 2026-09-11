#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let daemon = Daemon::new().await?;

    daemon.run().await?;

    Ok(())
}

/*
Itterum Shell CLI

ish --help

ish start
ish stop
ish reload

ish theme list
ish theme set tokyo-night

ish config validate

ish compositor status
*/
