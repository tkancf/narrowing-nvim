-- Test file for narrowing.nvim
-- This file can be used to test the narrowing functionality

local function test_function()
  print("This is a test function")
  print("You can select these lines")
  print("And narrow them to edit")
  print("Then write back the changes")
end

local test_table = {
  key1 = "value1",
  key2 = "value2",
  key3 = {
    nested = "value",
    another = "test"
  }
}

-- Test different selection types:
-- 1. Select this paragraph in visual line mode (V)
--    and use :Narrow or <leader>nr to narrow it
--    Edit the content and use <leader>nw to save
--    or <leader>nq to quit without saving

-- 2. You can also select partial text in character-wise
--    visual mode (v) to narrow specific portions

-- 3. Multiple narrowed regions can be opened simultaneously
--    from the same buffer

-- Sample code to test syntax highlighting preservation
local function calculate_sum(numbers)
  local sum = 0
  for _, num in ipairs(numbers) do
    sum = sum + num
  end
  return sum
end

-- Test with this list
local numbers = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
local result = calculate_sum(numbers)
print("Sum:", result)