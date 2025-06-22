# Narrowing.nvim - Development TODO

## Overview
Create a Neovim plugin in Lua that provides narrowing functionality similar to NrrwRgn, allowing users to focus on and edit specific text regions in isolated buffers.

## Core Features to Implement

### 1. Project Setup
- [ ] Initialize plugin directory structure
- [ ] Create main plugin entry point (lua/narrowing/init.lua)
- [ ] Set up basic plugin configuration structure
- [ ] Create plugin documentation structure

### 2. Core Narrowing Functionality
- [ ] Implement function to capture selected text region
- [ ] Create new buffer/window for narrowed content
- [ ] Store original buffer reference and position information
- [ ] Implement syntax highlighting preservation in narrowed buffer

### 3. Buffer Management
- [ ] Track relationship between original and narrowed buffers
- [ ] Implement buffer state management (track multiple narrowed regions)
- [ ] Handle buffer cleanup on close
- [ ] Prevent accidental modifications to original buffer

### 4. Write-back Functionality
- [ ] Implement function to write narrowed content back to original buffer
- [ ] Validate content before write-back
- [ ] Handle line number changes and offsets
- [ ] Implement undo/redo support for write-back operations

### 5. Commands and Keymaps
- [ ] Create `:Narrow` command for visual selection
- [ ] Create `:NarrowWrite` command to save changes
- [ ] Create `:NarrowQuit` command to close without saving
- [ ] Set up default keymaps (configurable)
- [ ] Add command completion support

### 6. Visual Mode Support
- [ ] Handle character-wise visual selection
- [ ] Handle line-wise visual selection
- [ ] Handle block-wise visual selection
- [ ] Support motion-based narrowing

### 7. Window and Layout Management
- [ ] Implement configurable window placement (split, vsplit, floating)
- [ ] Preserve window layout after narrowing
- [ ] Handle window resize events
- [ ] Implement focus management between windows

### 8. Advanced Features
- [ ] Support multiple simultaneous narrowed regions
- [ ] Implement diff view between original and narrowed content
- [ ] Add highlighting for changed regions
- [ ] Support for narrowing by text objects (function, paragraph, etc.)

### 9. Configuration Options
- [ ] Window size and position settings
- [ ] Keybinding customization
- [ ] Highlight group configuration
- [ ] Auto-save options
- [ ] Buffer naming patterns

### 10. Error Handling and Edge Cases
- [ ] Handle buffer modifications during narrowing
- [ ] Handle external file changes
- [ ] Validate narrowed region boundaries
- [ ] Handle plugin conflicts
- [ ] Implement proper error messages

### 11. Testing
- [ ] Set up test framework
- [ ] Write unit tests for core functions
- [ ] Create integration tests for commands
- [ ] Test edge cases and error scenarios

### 12. Documentation and Examples
- [ ] Write comprehensive help documentation
- [ ] Create README with installation instructions
- [ ] Add usage examples and GIFs
- [ ] Document API for extensibility

## Implementation Order
1. Basic project structure and entry point
2. Simple narrow and write-back functionality
3. Command implementation
4. Visual mode support
5. Window management
6. Configuration system
7. Advanced features
8. Testing and documentation