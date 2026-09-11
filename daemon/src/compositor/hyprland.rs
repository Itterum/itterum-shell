use super::*;

pub struct Hyprland;

impl Compositor for Hyprland {
    async fn workspaces(&self) -> Result<Vec<Workspace>, CompositorError> {
        todo!()
    }

    async fn windows(&self) -> Result<Vec<Window>, CompositorError> {
        todo!()
    }

    async fn focus_workspace(&self, id: &WorkspaceId) -> Result<(), CompositorError> {
        todo!()
    }

    async fn focus_window(&self, id: &WindowId) -> Result<(), CompositorError> {
        todo!()
    }

    async fn subscribe(&self) -> Result<EventStream, CompositorError> {
        todo!()
    }
}
