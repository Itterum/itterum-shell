mod compositor;

use anyhow::Result;
use std::sync::Arc;

use crate::compositor::{CompositorEvent, CompositorService};

enum AppEvent {
    Compositor(CompositorEvent),
}

struct AppState {
    pub compositor: Arc<CompositorService>,
}

struct Daemon {
    state: Arc<AppState>,
    ipc: IpcServer,
}

impl Daemon {
    pub async fn new() -> Result<Self> {
        let compositor = Arc::new(CompositorService::detect().await?);

        let state = Arc::new(AppState { compositor });

        let ipc = IpcServer::new(state.clone()).await?;

        Ok(Self { state, ipc })
    }

    pub async fn run(self) -> Result<()> {
        let compositor = self.state.compositor.clone();

        tokio::try_join!(compositor.run(), self.ipc.run(),)?;

        Ok(())
    }
}

#[tokio::main]
async fn main() -> Result<()> {
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
