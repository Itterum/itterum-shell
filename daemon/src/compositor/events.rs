enum CompositorEvent {
    WorkspacesChanged(Vec<Workspace>),
    WindowsChanged(Vec<Window>),

    WorkspaceFocused { id: WorkspaceId },

    WindowFocused { id: Option<WindowId> },

    WindowOpened(Window),

    WindowClosed { id: WindowId },
}
