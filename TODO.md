# Narrowing.nvim - Development TODO

## Overview
Create a Neovim plugin in Lua that provides narrowing functionality similar to NrrwRgn, allowing users to focus on and edit specific text regions in isolated buffers.

## Completed Features ✅

### 1. Project Setup
- [x] Initialize plugin directory structure
- [x] Create main plugin entry point (lua/narrowing/init.lua)
- [x] Set up basic plugin configuration structure
- [x] Create README with installation instructions

### 2. Core Narrowing Functionality
- [x] Implement function to capture selected text region
- [x] Create new buffer/window for narrowed content (floating window)
- [x] Store original buffer reference and position information
- [x] Implement syntax highlighting preservation in narrowed buffer

### 3. Basic Buffer Management
- [x] Track relationship between original and narrowed buffers
- [x] Implement basic buffer state management
- [x] Handle buffer cleanup on close

### 4. Write-back Functionality
- [x] Implement function to write narrowed content back to original buffer
- [x] Basic validation of buffer state before write-back

### 5. Commands and Keymaps
- [x] Create `:Narrow` command for visual selection
- [x] Create `:NarrowWrite` command to save changes
- [x] Create `:NarrowQuit` command to close without saving
- [x] Set up default keymaps (configurable)

### 6. Visual Mode Support
- [x] Handle character-wise visual selection
- [x] Handle line-wise visual selection
- [ ] Handle block-wise visual selection (partial support)
- [ ] Support motion-based narrowing

## Features to Implement

### 1. Enhanced Buffer Management
- [ ] Support multiple simultaneous narrowed regions from same buffer
- [ ] Prevent accidental modifications to original buffer
- [ ] Handle buffer modifications during narrowing
- [ ] Implement undo/redo support for write-back operations

### 2. Advanced Visual Mode Support
- [ ] Complete block-wise visual selection support
- [ ] Support motion-based narrowing

### 3. Window and Layout Management
- [x] Implement floating window with configurable position
- [ ] Add split/vsplit window options
- [ ] Preserve window layout after narrowing
- [ ] Handle window resize events
- [ ] Implement focus management between windows

### 4. Advanced Features
- [ ] Support multiple simultaneous narrowed regions
- [ ] Implement diff view between original and narrowed content
- [ ] Add highlighting for changed regions
- [ ] Support for narrowing by text objects (function, paragraph, etc.)
- [ ] Add line number display in narrowed buffer

### 5. Enhanced Configuration Options
- [x] Window size and position settings (basic)
- [x] Keybinding customization
- [ ] Highlight group configuration
- [ ] Auto-save options
- [ ] Buffer naming patterns
- [ ] Window border styles
- [ ] Custom window title format

### 6. Error Handling and Edge Cases
- [ ] Handle buffer modifications during narrowing
- [ ] Handle external file changes
- [ ] Validate narrowed region boundaries
- [ ] Handle plugin conflicts
- [ ] Implement proper error messages
- [ ] Add confirmation prompts for destructive actions

### 7. Testing
- [x] Create basic test file (test_narrowing.lua)
- [ ] Set up proper test framework (plenary.nvim)
- [ ] Write unit tests for core functions
- [ ] Create integration tests for commands
- [ ] Test edge cases and error scenarios

### 8. Documentation and Examples
- [ ] Write comprehensive help documentation (:help narrowing)
- [x] Create README with installation instructions
- [ ] Add usage examples and GIFs
- [ ] Document API for extensibility
- [ ] Create example configurations

## Next Priority Tasks
1. Complete block-wise visual selection support
2. Add split/vsplit window options
3. Implement multiple simultaneous narrowed regions
4. Add proper error handling and validation
5. Create help documentation
6. Set up automated tests with plenary.nvim

## Future Enhancements
- Integration with other plugins (telescope.nvim for narrowed region selection)
- Session persistence (save/restore narrowed regions)
- Custom highlight groups for narrowed content
- Performance optimizations for large files
- Add support for narrowing based on treesitter nodes