export default () => ({
  canCommit: false,
  currentProjectId: '',
  currentBranchId: '',
  currentBlobView: 'repo-editor',
  discardPopupOpen: false,
  editMode: true,
  endpoints: {},
  isRoot: false,
  isInitialRoot: false,
  lastCommitPath: '',
  loading: false,
  onTopOfBranch: false,
  openFiles: [],
  selectedFile: null,
  path: '',
  parentTreeUrl: '',
  trees: {},
  projects: {},
  leftPanelCollapsed: false,
  rightPanelCollapsed: true,
  panelResizing: false,
});
