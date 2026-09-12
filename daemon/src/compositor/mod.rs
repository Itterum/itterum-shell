mod events;
mod hyprland;
mod models;
mod niri;
mod service;

pub use events::*;
pub use hyprland::*;
pub use models::*;
pub use niri::*;
pub use service::*;

pub trait Compositor {
    async fn get_workspaces(&self) -> Result<Vec<Workspace>, CompositorError>;

    async fn get_windows(&self) -> Result<Vec<Window>, CompositorError>;

    async fn focus_workspace(&self, id: &WorkspaceId) -> Result<(), CompositorError>;

    async fn focus_window(&self, id: &WindowId) -> Result<(), CompositorError>;

    async fn subscribe(&self) -> Result<EventStream, CompositorError>;
}
