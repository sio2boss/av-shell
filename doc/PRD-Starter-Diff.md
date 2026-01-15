# Product Requirements Document: Starter Diff Tool

## 1. Overview

### 1.1 Product Name
**Starter Diff Tool** (`starter-diff`)

### 1.2 Purpose
A terminal-based interactive TUI (Text User Interface) application that compares a starter/template directory structure (left side) with a target project directory (right side), displaying differences in a side-by-side tree view. The tool helps developers identify which files have been modified, added, or deleted when comparing a starter template against a project that was created from it.

## 2. Core Features

### 2.1 Directory Comparison
- **Input**: Two directory paths (source/starter directory and target/project directory)
- **Process**: 
  - Recursively scans both directories
  - Builds hierarchical tree structures
  - Compares file contents using MD5 hashing
  - Identifies differences between source and target
- **Output**: Side-by-side tree view showing file status

### 2.2 File Status Classification
The application categorizes files into the following statuses:

| Status | Description | Color Code |
|--------|-------------|------------|
| **Unchanged** | File exists in both directories with identical content | White |
| **Modified** | File exists in both directories but content differs | Yellow |
| **Added** | File exists in source but not in target | Green |
| **Deleted** | File exists in target but not in source | Purple |
| **Conflict** | Type mismatch (e.g., directory in one, file in other) | Magenta |
| **Rejected** | File marked by user to be excluded from consideration | Gray |

### 2.3 File Exclusion Rules
The application excludes directories/files from comparison using both default and configurable patterns.

#### 2.3.1 Default Exclusion Patterns
The following patterns are automatically excluded:
- `.git` directories
- `node_modules` directories
- `.venv` directories
- `.av` directories
- `.idea` directories
- `__pycache__` directories
- `.DS_Store` files

**Note**: `.gitignore` files are **not** excluded by default and will be included in comparisons.

#### 2.3.2 Configurable Exclusion Patterns
Additional exclusion patterns can be specified via the `--exclude` CLI argument. Patterns are matched against file and directory names (not full paths) using case-sensitive exact matching. Multiple patterns can be specified by using the `--exclude` argument multiple times.

**Examples**:
- `--exclude build` excludes directories/files named `build`
- `--exclude .env` excludes files/directories named `.env`
- `--exclude dist --exclude target` excludes both `dist` and `target`

## 3. User Interface

### 3.1 Main View Layout
The application displays a split-screen interface using tview Tree widgets:

```
┌─────────────────────────┬─────────────────────────┐
│   Source (Starter)     -->  Target (Project)      │
├─────────────────────────┼─────────────────────────┤
│  Filter: [pattern]      │  ▶ config/              │
│  ▶ config/              │  ▶ src/                │
│  ▶ src/                 │    ├── file1.go         │
│    ├── file1.go         │    └── file2.go         │
│    └── file2.go         │                         │
└─────────────────────────┴─────────────────────────┘
Enter: diff | 'r': reject | Shift+R: reject all | → expand | ← collapse | '/' filter | 'h': help (color key) | 'q' or Esc: exit
```

**Tree Widget Features**:
- `▶` indicates collapsed directory (can be expanded)
- `▼` indicates expanded directory (can be collapsed)
- Tree widget handles indentation and tree connectors automatically
- Directories can be expanded/collapsed individually

**Filter Text Field**:
- Appears at the top of the focused column (source or target) when pattern filtering is active
- Embedded inline with the file tree display
- Shows "Filter: [pattern]" where pattern is the user-entered text
- Only visible when filter is active (non-empty pattern)
- Filters files and directories whose paths match the pattern (case-insensitive substring match)

### 3.2 Visual Elements

#### 3.2.1 Tree Structure
- Uses tview's `Tree` widget to display hierarchical directory structure
- Provides native tree rendering with expandable/collapsible nodes
- Directories can be expanded or collapsed to show/hide their contents
- Directories are marked with visual indicators (typically `▶` for collapsed, `▼` for expanded)
- Files and directories are sorted alphabetically for consistent display
- Tree widget handles indentation and tree connectors automatically

#### 3.2.2 Color Coding
- **Yellow**: Modified files
- **Green**: Added files (exist in source only)
- **Purple**: Deleted files (only in target/project)
- **Magenta**: Conflict (type mismatch)
- **Gray**: Rejected files
- **White**: Unchanged files

**Note**: A complete color key is available at the top of the help dialog (press `h` to view).

#### 3.2.3 Selection Highlighting
- Selected items use blue background with white text
- Selection is automatically synchronized between source and target lists
  - When a file is selected in one tree, the corresponding file (by relative path) is automatically selected in the other tree
  - Works for both files and directories
  - Synchronization occurs automatically as user navigates with arrow keys
- Only one item can be selected at a time per list
- Selection is preserved when:
  - Rejecting files or directories
  - Toggling between "show all" and "changed only" views
  - Applying or clearing filters
  - Returning from diff view

### 3.3 Filtering

#### 3.3.1 Status-Based Filtering
- **Default View**: Shows only changed files (Modified, Added, Deleted, Conflict, Rejected)
- **Toggle View**: Press `a` to toggle between "changed only" and "show all files"
- Rejected files remain visible even when originally unchanged

#### 3.3.2 Pattern-Based Filtering
- **Trigger**: Press `/` to activate pattern filter
- **Behavior**: 
  - Embedded text field appears at the top of the currently focused column (source or target)
  - User types pattern to filter file paths
  - Filtering is case-insensitive substring matching
  - Files and directories whose paths contain the pattern are shown
  - Filter applies to both source and target lists simultaneously
  - Filter persists until cleared or application exits
- **Clearing Filter**: 
  - Press `Escape` while in filter input to clear pattern
  - Or delete all characters in filter field
  - When filter is cleared, returns to previous view (status-based filtering)

## 4. User Interactions

### 4.1 Navigation

#### 4.1.1 List Navigation (Main View)
| Key | Action |
|-----|--------|
| `↑` / `↓` | Move selection up/down one item |
| `Page Up` / `Page Down` | Scroll by page (10 items) |
| `Home` | Jump to top of list |
| `End` | Jump to bottom of list |
| `Tab` | Switch focus between source and target lists |
| `/` | Activate pattern filter (shows embedded text field) |
| `→` (right arrow) | Expand selected directory (if collapsed) |
| `←` (left arrow) | Collapse directory: if on a directory, collapses it; if on a file/child item within a directory, collapses the parent directory |
| `Space` or `Enter` (on directory) | Toggle expand/collapse directory node (alternative to arrow keys) |
| `r` | Toggle rejection status for selected file or directory |

#### 4.1.2 Mouse Support
- **Scroll Up**: Move selection up one item
- **Scroll Down**: Move selection down one item
- Works on both source and target lists
- Works in diff view for scrolling content

#### 4.1.3 Directory Expand/Collapse Behavior
The left and right arrow keys provide intuitive navigation for expanding and collapsing directories:

- **Right Arrow (`→`)**:
  - When a collapsed directory is selected, expands it to show its contents
  - No effect if directory is already expanded or if selection is on a file

- **Left Arrow (`←`)**:
  - **When on a directory**: Collapses the selected directory, hiding its contents
  - **When on a file or child item**: Collapses the parent directory that contains the selected item
  - This allows quick navigation up the tree hierarchy by collapsing parent directories

**Examples**:
- User navigates into `src/components/Button.tsx` → pressing `←` collapses `components` directory
- User selects `config/` directory → pressing `→` expands it, pressing `←` collapses it
- User is viewing `src/utils/helper.go` → pressing `←` collapses `utils` directory

**Alternative Methods**:
- `Space` or `Enter` on a directory also toggles expand/collapse state
- These methods only work when the selection is directly on a directory node

### 4.2 Actions

#### 4.2.1 File Diff Dialog
- **Trigger**: Press `Enter` on a selected file (not a directory)
- **Note**: Pressing `Enter` on a directory expands/collapses it instead of opening diff
- **Behavior**:
  - Opens a modal dialog showing the diff between source and target files
  - Uses `diff` command with unified format (`diff -u`)
  - **Diff Direction**: Shows changes needed in target to match source (uses `diff -u <target> <source>`)
    - Lines prefixed with `-` are in target but not in source (should be removed)
    - Lines prefixed with `+` are in source but not in target (should be added)
  - Displays loading message while computing diff
  - Shows syntax-highlighted diff output:
    - Yellow: File headers (`+++`, `---`)
    - Cyan: Hunk headers (`@@`)
    - Green: Added lines (`+`)
    - Red: Deleted lines (`-`)
  - Handles special cases:
    - Added files: compares against `/dev/null`
    - Deleted files: compares `/dev/null` against target file
    - Identical files: shows "No differences found" message
    - Timeout: Shows error after 30 seconds
  - Footer displays keyboard navigation options like `r` and `backspace`

#### 4.2.2 Diff Dialog Navigation
| Key | Action |
|-----|--------|
| `↑` / `↓` | Scroll diff content up/down one line |
| `Page Up` / `Page Down` | Scroll diff by page (10 lines) |
| `Home` | Jump to top of diff |
| `End` | Jump to bottom of diff |
| `Backspace`,`Escape`, `q` | Close diff view and return to main view |
| `r` | Reject the file and return to main view |

#### 4.2.3 File and Directory Rejection
- **Purpose**: Mark files or directories to exclude from consideration
- **Trigger**: 
  - Press `r` on the main view while a file or directory is selected
  - Press `Shift+R` on the main view to reject all files
  - Press `r` while viewing a file diff
- **Behavior**:
  - **For All Files (Shift+R)**:
    - Marks all files in both source and target trees as rejected
    - Updates status of all files in both trees to `StatusRejected`
    - Refreshes tree views to show all files as rejected (gray color)
    - Selection remains unchanged after operation
  - **For Individual Files**: 
    - Marks both source and target file paths as rejected (stored in `rejectedFiles` map)
    - Updates status of both source and target FileNode structures to `StatusRejected`
    - Selection remains on the rejected file after operation
  - **For Directories**:
    - Recursively marks all files within the directory (and subdirectories) as rejected
    - Updates status of all files within the directory in both source and target trees
    - When un-rejecting a directory, recalculates status for all files within it
    - Selection remains on the directory after operation
  - **General**:
    - Refreshes tree views to show updated rejected status (gray color)
    - Rejected files display "[rejected]" suffix
    - Rejected files remain visible in filtered view
    - Rejection persists across view changes and is written to output file on exit
    - Toggle behavior: Pressing `r` again on a rejected file/directory will un-reject it

#### 4.2.4 Pattern Filtering
- **Trigger**: Press `/` on main view
- **Behavior**: 
  - Replaces main view with text input field for filter entry
  - User can type pattern to filter files by path
  - Filtering is real-time (updates as user types via `SetChangedFunc`)
  - Case-insensitive substring matching on file/directory paths
  - Filter applies to both source and target lists simultaneously
  - Filter field shows "Filter: " label with user-entered pattern
- **Filter Input Navigation**:
  - Standard text editing: backspace to delete, arrow keys move cursor
  - `Escape`: Clears filter pattern and returns to main view
  - `Enter`: Confirms current filter (stays in filter mode, can continue typing)
  - Filter input has its own input capture that handles Escape key
- **Filter Persistence**: Filter pattern remains active until cleared with Escape or application exits
- **Implementation Note**: Filter input replaces the root view temporarily; main layout input capture is inactive during filter mode

#### 4.2.5 Help Dialog
- **Trigger**: Press `h` or `H`
- **Content**: 
  - **Color Key** (displayed at the top): Shows all file status colors with descriptions:
    - Yellow: Modified files
    - Green: Added files
    - Purple: Only in target/project
    - Magenta: Conflict (file vs directory)
    - Gray: Rejected files
    - White: Unchanged files
  - **Keyboard Shortcuts**: Comprehensive reference for all keyboard commands
- **Navigation**:
  - Scrollable text view
  - Close button available
  - Press `h`, `Escape`, `q` to dismiss the dialog
- **Behavior**: Returns to main view when closed (does not exit application)

#### 4.2.6 Application Exit
- **Trigger**: Press `q`, `Q`, or `Escape` (when no dialogs are open)
- **Behavior**: 
  1. Displays confirmation prompt: "Apply changes? (y/n): "
  2. User can press:
     - `y` or `Y`: Apply changes and exit with code 0 (success)
     - `n` or `N`: Cancel and exit with code 1 (cancelled)
     - `Escape`: Cancel exit dialog and return to main view (does not exit application)
     - Any other key: Ignored, prompt remains visible
  3. If `--output` parameter was provided, writes list of rejected files to the specified output file before exiting (regardless of y/n choice)
  4. Output file is written even if user cancels exit with `Escape` (on next exit attempt)
- **Note**: When in help or diff views, `q`/`Escape` return to main view instead of showing exit dialog

### 4.3 Display Toggle
- **Key**: `a` or `A`
- **Action**: Toggles between "show all files" and "show changed files only"
- **Default**: Changed files only
- **Behavior**: 
  - Immediately updates both source and target lists
  - Preserves current selection when toggling view

## 5. Technical Specifications

### 5.1 Command-Line Interface

#### 5.1.1 Usage
```bash
starter-diff <source_dir> <target_dir> [--output <output_file>] [--exclude <pattern>]...
```

#### 5.1.2 Arguments
- `source_dir`: Path to starter/template directory (required)
- `target_dir`: Path to target project directory (required)
- `--output <output_file>`: Path to file where rejected files list will be written on exit (optional)
- `--exclude <pattern>`: Additional exclusion pattern to exclude from comparison (optional, can be specified multiple times)
  - Pattern matches file/directory names exactly (case-sensitive)
  - Can be used multiple times to exclude multiple patterns
  - Examples: `--exclude build`, `--exclude .env`, `--exclude dist --exclude target`

#### 5.1.3 Help Options
- `--help` or `-h`: Display usage information and exit
- If `AV_SINGLE_LINE_HELP` environment variable is set, `-h` returns single-line description

#### 5.1.4 Path Handling
- Accepts both absolute and relative paths
- Automatically converts relative paths to absolute paths
- Validates that both directories exist and are directories

#### 5.1.5 Exit Codes
- `0`: Success (user confirmed to apply changes)
- `1`: Error or cancellation (user chose not to apply changes)
- `> 1`: Various error conditions (invalid paths, missing directories, etc.)

#### 5.1.6 Output File Format
- When `--output` parameter is provided, rejected files are written to the specified file on exit
- File format: One file path per line (relative paths from target directory root)
- File is written regardless of whether user chooses to apply changes (y) or not (n)
- If the output file already exists, it will be overwritten
- If the output directory does not exist, the application will attempt to create parent directories

### 5.2 File Comparison Algorithm

#### 5.2.1 Tree Building
1. Recursively walks source directory
2. Recursively walks target directory
3. Builds hierarchical tree structures for both
4. Excludes directories/files matching default patterns (`.git`, `node_modules`, `.venv`, `.av`, `.idea`)
5. Excludes directories/files matching any patterns specified via `--exclude` arguments
6. Exclusion matching is performed during directory walk (early exclusion for performance)
7. Pattern matching is case-sensitive and matches file/directory names exactly
8. Converts FileNode structures into tview Tree widget nodes
9. Tree widget provides native expand/collapse functionality and visual tree rendering

#### 5.2.2 Comparison Process
1. Compares file names at each level
2. For matching files:
   - Reads both files
   - Computes MD5 hash of each file
   - Compares hashes to determine if modified
3. Identifies files only in source (Added)
4. Identifies files only in target (Deleted)
5. Detects type mismatches (file vs directory) as Conflicts

#### 5.2.3 Diff Generation
- **Primary Method**: Uses standard `diff -u` command on non-binary files
- **Diff Direction**: Shows changes needed in target to match source (uses `diff -u <target> <source>`)
- **Timeout**: 30-second timeout to prevent hanging
- **Error Handling**: Gracefully handles missing files, timeouts, and identical files

### 5.3 Performance Considerations
- Asynchronous diff computation (non-blocking UI)
- Context-based timeout for diff commands
- Efficient tree building with early exclusion
- MD5 hashing for fast content comparison

## 6. User Experience Flow

### 6.1 Startup Flow
1. User runs command with two directory paths
2. Application validates paths
3. Builds file trees for both directories
4. Compares trees and computes file statuses
5. Converts FileNode structures to tview Tree widget nodes
6. Displays main view with filtered (changed files only) by default
7. Directories start in collapsed state (user can expand as needed)
8. Focus is set to source list

### 6.2 Typical Workflow
1. **Review Changes**: User navigates through changed files using arrow keys
2. **Expand/Collapse Directories** (optional): User presses `→` to expand directories, `←` to collapse (collapses parent when on child items), or `Space`/`Enter` to toggle directories
3. **Filter by Pattern** (optional): User presses `/` to filter files by path pattern
4. **Reject Files/Directories** (optional): 
   - User presses `r` on files or directories to toggle rejection status
   - User presses `Shift+R` to reject all files at once
   - Rejecting a directory rejects all files within it recursively
   - Selection remains on the rejected item after operation
5. **Inspect Details**: User presses `Enter` on a file to view diff
6. **Evaluate Changes**: User reviews diff output
7. **Reject from Diff View** (optional): User presses `r` while viewing diff to toggle reject status
8. **Continue Review**: User presses `Backspace` to return and continue (selection preserved)
9. **Toggle View**: User presses `a` to see all files if needed (selection preserved)
10. **Clear Filter** (if active): User presses `Escape` to clear pattern filter (selection preserved)
11. **Get Help**: User presses `h` to view keyboard shortcuts
12. **Exit**: User presses `q` to exit application
13. **Confirm Changes**: User is prompted "Apply changes? (y/n): "
14. **Apply or Cancel**: User presses `y` to apply changes or `n` to cancel
15. **Output Rejected Files**: If `--output` was provided, rejected files list is written to the output file

### 6.3 Error Handling
- Invalid paths: Clear error messages, exit with error code
- Missing directories: Validation before processing
- Diff command failures: Error messages displayed in diff view
- Timeouts: 30-second timeout with clear error message
- Empty diffs: Handled gracefully with appropriate messages

## 7. Implementation Architecture

### 7.1 Code Structure
The application is implemented as a single `main.go` file containing:
- Data structures (`FileNode`, `FileStatus`, `AppState`)
- Core algorithms (tree building, comparison, MD5 hashing)
- TUI components and event handlers
- All application logic in one cohesive unit

### 7.2 Input Capture Architecture
The application uses a hierarchical input capture system where each view/dialog manages its own keyboard input:

#### 7.2.1 Main Layout Input Capture
- **Location**: Set on `mainLayout` (not app-level)
- **Purpose**: Handles global application commands when main view is active
- **Handled Keys**:
  - Character keys: `q`, `h`, `a`, `/`, `r`, `Space` (via `event.Rune()`)
  - Modified keys: `Shift+R` (via `event.Rune()` and `event.Modifiers()`)
  - Special keys: `Escape`, `Ctrl+C`, `Tab`, `Enter`, `→`, `←` (via `event.Key()`)
- **Behavior**: Returns `nil` to consume handled events, `event` to pass through to tree views

#### 7.2.2 Tree View Input Capture
- **Location**: Set on both `sourceTreeView` and `targetTreeView`
- **Purpose**: Allows app-level keys to bubble up to main layout handler
- **Handled Keys**: Returns `nil` for app-level keys (`q`, `h`, `a`, `/`, `r`, `Escape`, `Enter`, `→`, `←`, `Tab`) to bubble up
- **Behavior**: Returns `event` for navigation keys (`↑`, `↓`, `PageUp`, `PageDown`, `Home`, `End`) to let tree views handle them

#### 7.2.3 Dialog Input Capture
Each dialog/view has its own input capture handler:

- **Help Dialog**: Handles `h`, `q`, `Escape` to close and return to main view
- **Exit Dialog**: Handles `y`, `n` to confirm/cancel, `Escape` to cancel and return to main view
- **Diff View**: Handles `r` to reject file, `q`, `Escape`, `Backspace` to close, plus scrolling keys
- **Filter Input**: Handles text input and `Escape` to clear filter

#### 7.2.4 Event Handling Pattern
- **Character Keys**: Use `event.Rune()` to detect regular characters (`q`, `h`, `a`, `/`, `r`, `y`, `n`, `Space`)
- **Special Keys**: Use `event.Key()` to detect special keys (`Escape`, `Tab`, `Enter`, `→`, `←`, `Ctrl+C`)
- **Event Bubbling**: Returning `nil` from input capture consumes the event; returning `event` passes it through

### 7.3 Data Structures

#### 7.3.1 FileNode
Represents a file or directory in the tree:
```go
type FileNode struct {
    Name     string      // File/directory name
    Path     string      // Full absolute path
    IsDir    bool        // Whether this is a directory
    Status   FileStatus  // Comparison status
    Children []*FileNode // Child nodes
    Parent   *FileNode   // Parent node reference
}
```

#### 7.3.2 FileStatus
Enumeration of file comparison statuses:
- `StatusUnchanged`: File exists in both with identical content
- `StatusModified`: File exists in both but content differs
- `StatusAdded`: File exists only in source
- `StatusDeleted`: File exists only in target
- `StatusConflict`: Type mismatch (file vs directory)
- `StatusRejected`: File marked as rejected by user

#### 7.3.3 AppState
Central application state container:
```go
type AppState struct {
    sourceDir       string          // Absolute path to source directory
    targetDir       string          // Absolute path to target directory
    outputFile      string          // Output file path for rejected files
    excludePatterns []string         // Custom exclusion patterns
    sourceTree      *FileNode        // Source directory tree
    targetTree      *FileNode        // Target directory tree
    rejectedFiles   map[string]bool // Map of rejected file paths
    showAll         bool            // Toggle for show all vs changed only
    filterPattern   string          // Current pattern filter
}
```

### 7.4 Tree Building Algorithm

#### 7.4.1 Directory Walk
- Uses `filepath.Walk()` to recursively scan directories
- Early exclusion: Skips excluded directories during walk (via `filepath.SkipDir`)
- Builds parent-child relationships as it encounters files/directories
- Creates intermediate directory nodes when needed

#### 7.4.2 Tree Comparison
- Recursively compares nodes at each level
- Builds maps of children by name for efficient lookup
- Computes MD5 hashes for file content comparison
- Sets status on both source and target nodes simultaneously
- Handles type mismatches and missing files

### 7.5 View Management

#### 7.5.1 View Switching
- Uses `app.SetRoot()` to switch between views
- Each view maintains its own input capture
- Views can return to `mainLayout` by calling `app.SetRoot(mainLayout, true)`

#### 7.5.2 Tree Refresh
- `refreshTrees()` function rebuilds tree views from FileNode structures
- Accepts optional `preserveSelection` parameter (variadic `...bool`)
- When `preserveSelection` is `true`:
  - Stores current selection paths (relative paths) before refresh
  - After rebuilding trees, finds and restores selection to the same paths
  - Falls back to root if the path is no longer visible (filtered out)
- Called after: status changes, filter changes, rejection actions
- Applies current filter pattern and showAll setting
- Converts FileNode structures to tview TreeNode structures
- Selection preservation is used for: rejection operations, filter changes, view toggles, closing diff view

### 7.6 Diff Generation

#### 7.6.1 Asynchronous Processing
- Diff computation runs in goroutine to avoid blocking UI
- Shows loading modal while computing diff
- Uses context with 30-second timeout

#### 7.6.2 Diff Command Execution
- Uses `exec.CommandContext()` with timeout context
- Handles special cases:
  - Added files: `diff -u /dev/null <source>`
  - Deleted files: `diff -u <target> /dev/null`
  - Modified files: `diff -u <target> <source>` (shows changes needed in target to match source)

#### 7.6.3 Syntax Highlighting
- Parses diff output line by line
- Applies color codes:
  - Yellow: File headers (`+++`, `---`)
  - Cyan: Hunk headers (`@@`)
  - Green: Added lines (`+`)
  - Red: Deleted lines (`-`)
  - White: Context lines

### 7.7 File and Directory Rejection System

#### 7.7.1 Rejection Storage
- Uses `map[string]bool` keyed by relative paths
- Stores file paths (not directory paths) - directories are rejected by rejecting all files within them
- Persists across view changes

#### 7.7.2 Rejection Propagation
- **File Rejection**:
  - When rejecting a file (from main view or diff view), updates both source and target nodes
  - Uses `findAndUpdateNode()` helper to locate corresponding nodes
  - Sets status to `StatusRejected` for both nodes
- **Directory Rejection**:
  - Uses `rejectDirectory()` helper function to recursively reject all files within a directory
  - Processes both source and target trees simultaneously
  - When un-rejecting a directory, uses `recalculateDirectoryStatus()` to restore original statuses
- **Reject All Files**:
  - Triggered by `Shift+R` keyboard shortcut
  - Uses `rejectAllFiles()` helper function to walk through both source and target trees
  - Recursively marks all files in both trees as rejected
  - Updates status of all files to `StatusRejected`
  - Refreshes tree views to show updated status
- **Selection Preservation**:
  - `refreshTrees()` function accepts optional `preserveSelection` parameter
  - When `true`, stores current selection paths before refresh and restores them after
  - Used for rejection, filter changes, and view toggles to maintain user's position
- **Selection Synchronization**:
  - Both tree views have `SetChangedFunc` handlers that synchronize selection
  - When a file is selected in one tree, the corresponding file (by relative path) is automatically selected in the other tree
  - Uses `findTreeNodeByRelPath()` helper to locate corresponding nodes
  - `syncingSelection` flag prevents infinite recursion during synchronization
- **Visual Feedback**:
  - Refreshes tree views to show updated status
  - Rejected files show gray color and "[rejected]" suffix

### 7.8 Output File Writing

#### 7.8.1 Write Timing
- Writes rejected files list on exit (both `y` and `n` responses)
- Creates parent directories if needed (`os.MkdirAll()`)
- Overwrites existing file if present

#### 7.8.2 File Format
- One relative path per line
- Paths relative to target directory root
- Sorted alphabetically for consistency
- Only includes paths that exist in target directory

## 8. Dependencies

### 8.1 Required
- Go 1.21+
- Terminal with TUI support
- `diff` command (for diff functionality)

### 8.2 External Libraries
- `github.com/rivo/tview`: TUI framework
- `github.com/gdamore/tcell/v2`: Terminal cell library
