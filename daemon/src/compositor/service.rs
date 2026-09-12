use crate::compositor::{Compositor, Hyprland, Niri, Workspace, WorkspaceId};

pub struct CompositorService {
    backend: Box<dyn Compositor + Send + Sync>,
}

impl CompositorService {
    pub async fn detect() -> anyhow::Result<Self> {
        let backend: Box<dyn Compositor + Send + Sync> =
            if std::env::var("HYPRLAND_INSTANCE_SIGNATURE").is_ok() {
                Box::new(Hyprland::connect().await?)
            } else if std::env::var("NIRI_SOCKET").is_ok() {
                Box::new(Niri::connect().await?)
            } else {
                anyhow::bail!("unsupported compositor");
            };

        Ok(Self { backend })
    }

    pub async fn workspaces(&self) -> Result<Vec<Workspace>, CompositorError> {
        self.backend.get_workspaces().await
    }

    pub async fn focus_workspace(&self, id: &WorkspaceId) -> Result<(), CompositorError> {
        self.backend.focus_workspace(id).await
    }
}
