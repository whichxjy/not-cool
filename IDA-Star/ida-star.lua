-- title:  not cool
-- author: whichxjy
-- desc:   not cool
-- script: lua

-- Sprite ID
START = 1
PATH = 2
GOAL = 3
WALL = 4

-- Button ID
UP = 0
DOWN = 1
LEFT = 2
RIGHT = 3
A = 4
B = 5

-- Map
MAP_X_BEGIN = 1
MAP_X_END = 28
MAP_Y_BEGIN = 1
MAP_Y_END = 28
CELL_NUM = (MAP_X_END - MAP_X_BEGIN + 1) * (MAP_Y_END - MAP_Y_BEGIN + 1)

-- Initialize start cell and goal cell
start = {
    x = 1,
    y = 1,
    parent = nil
}

goal = {
    x = 4,
    y = 1,
    parent = nil
}

-- Who is being controlled?
ctrl = goal

-- Are these two cells in the same position?
function equal_pos(lhs, rhs)
    return (lhs.x == rhs.x and lhs.y == rhs.y)
end

-- Check if an item is already in a given table
function table.contains(tbl, item)
    for _, v in pairs(tbl) do
        if equal_pos(v, item) then
            return true
        end
    end

    return false
end

-- Check if it's the wall
function is_wall(x, y)
    return mget(x, y) == WALL
end

-- Iterative Deepening A*
function IDAStar(start, goal)
    local visited = {}

    -- Check validity
    local function is_free(cell)
        return (not table.contains(visited, cell)
                and not is_wall(cell.x, cell.y))
    end

    -- Manhattan distance between the cell and goal
    local function distance(cell)
        return math.abs(cell.x - goal.x) + math.abs(cell.y - goal.y)
    end

    -- Is the goal found?
    local found = false

    -- Cost-Limited Search
    local function CLS(curr, curr_g, limit_f)
        -- f = g + h
        local curr_f = curr_g + distance(curr)

        if (curr_f > limit_f) then
            return
        end

        -- Check if it's the goal
        if equal_pos(curr, goal) then
            goal.parent = curr.parent
            found = true
            return
        end

        -- Visit the current cell
        table.insert(visited, curr)

        -- Get the four adjacents to the current cell
        local up = {
            x = curr.x,
            y = curr.y - 1,
            parent = curr
        }
        if not found and is_free(up) then
            CLS(up, curr_g + 1, limit_f)
        end

        local down = {
            x = curr.x,
            y = curr.y + 1,
            parent = curr
        }
        if not found and is_free(down) then
            CLS(down, curr_g + 1, limit_f)
        end

        local left = {
            x = curr.x - 1,
            y = curr.y,
            parent = curr
        }
        if not found and is_free(left) then
            CLS(left, curr_g + 1, limit_f)
        end

        local right = {
            x = curr.x + 1,
            y = curr.y,
            parent = curr
        }
        if not found and is_free(right) then
            CLS(right, curr_g + 1, limit_f)
        end
    end

    if not is_free(start) then
        return false
    end

    -- Start IDA*
    for limit_f = 1, CELL_NUM do
        visited = {}
        CLS(start, 0, limit_f)
        if found then
            return true
        end
    end

    return false
end

function TIC()
    -- "UP" button is pressed
    if btn(UP) and not is_wall(ctrl.x, ctrl.y - 1) then
        ctrl.y = ctrl.y - 1
    end

    -- "DOWN" button is pressed
    if btn(DOWN) and not is_wall(ctrl.x, ctrl.y + 1) then
        ctrl.y = ctrl.y + 1
    end

    -- "LEFT" button is pressed
    if btn(LEFT) and not is_wall(ctrl.x - 1, ctrl.y) then
        ctrl.x = ctrl.x - 1
    end

    -- "RIGHT" button is pressed
    if btn(RIGHT) and not is_wall(ctrl.x + 1, ctrl.y) then
        ctrl.x = ctrl.x + 1
    end

    -- "A" button is pressed
    if btn(A) then
        ctrl = start
    end

    -- "B" button is pressed
    if btn(B) then
        ctrl = goal
    end
    
    -- Draw map
    cls()
    map(0, 0)

    -- Draw path
    if IDAStar(start, goal) then
        local cell = goal
        while cell.parent do
            spr(PATH, cell.x * 8, cell.y * 8)
            cell = cell.parent
        end
    end

    -- Draw start
    spr(START, start.x * 8, start.y * 8)

    -- Draw goal
    spr(GOAL, goal.x * 8, goal.y * 8)
end
