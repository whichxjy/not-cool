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
WIDTH = 28
HEIGHT = 15

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

-- Iterative Deepening DFS
function IDDFS(start, goal)
    local visited = {}

    -- Check validity
    local function is_free(cell)
        return (not table.contains(visited, cell)
                and not is_wall(cell.x, cell.y))
    end

    -- Is the goal found?
    local found = false

    -- Depth-Limited Search
    local function DLS(curr, limit)
        -- Check if it's the goal
        if equal_pos(curr, goal) then
            goal.parent = curr.parent
            found = true
            return
        end

        if (limit <= 0) then
            return
        end

        -- Visit the current cell
        table.insert(visited, curr)

        -- Visit the four adjacents to the current cell
        local up = {
            x = curr.x,
            y = curr.y - 1,
            parent = curr
        }
        if not found and is_free(up) then
            DLS(up, limit - 1)
        end

        local down = {
            x = curr.x,
            y = curr.y + 1,
            parent = curr
        }
        if not found and is_free(down) then
            DLS(down, limit - 1)
        end

        local left = {
            x = curr.x - 1,
            y = curr.y,
            parent = curr
        }
        if not found and is_free(left) then
            DLS(left, limit - 1)
        end

        local right = {
            x = curr.x + 1,
            y = curr.y,
            parent = curr
        }
        if not found and is_free(right) then
            DLS(right, limit - 1)
        end
    end

    if not is_free(start) then
        return false
    end

    -- Start IDDFS
    for depth = 1, (WIDTH * HEIGHT) do
        visited = {}
        DLS(start, depth)
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
    if IDDFS(start, goal) then
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
