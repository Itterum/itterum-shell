use super::*;

pub struct Niri;

impl Compositor for Niri {
    async fn get_workspaces(&self) -> Result<Vec<Workspace>, CompositorError> {
        todo!()
    }

    async fn get_windows(&self) -> Result<Vec<Window>, CompositorError> {
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
