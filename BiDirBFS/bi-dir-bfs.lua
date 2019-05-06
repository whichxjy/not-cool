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

-- Create Queue
function create_queue()
    local queue = {
        items = {}
    }

    function queue:push(item)
        table.insert(self.items, item)
    end

    function queue:pop()
        if self:is_empty() then
            return nil
        else
            return table.remove(self.items, 1)
        end
    end

    function queue:is_empty()
        if #self.items == 0 then
            return true
        else
            return false
        end
    end

    return queue
end

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

-- Intersecting Cell
s_iCell = nil
g_iCell = nil

-- Bidirectional BFS
function BiDirBFS(start, goal)
    -- visited[] for start
    local s_visited = {}
    -- visited[] for goal
    local g_visited = {}

    -- Check validity
    local function s_is_free(cell)
        return (not table.contains(s_visited, cell)
                and not is_wall(cell.x, cell.y))
    end

    local function g_is_free(cell)
        return (not table.contains(g_visited, cell)
                and not is_wall(cell.x, cell.y))
    end

    -- Check for intersecting cell
    local function intersect(s_visited, g_visited)
        for _, s_cell in pairs(s_visited) do
            for _, g_cell in pairs(g_visited) do
                if equal_pos(s_cell, g_cell) then
                    s_iCell = s_cell
                    g_iCell = g_cell
                    return true
                end
            end
        end

        return false
    end

    if not s_is_free(start) or not g_is_free(goal) then
        return false
    end

    local s_queue = create_queue()
    local g_queue = create_queue()

    table.insert(s_visited, start)
    s_queue:push(start)

    table.insert(g_visited, goal)
    g_queue:push(goal)
    
    while not s_queue:is_empty() and not g_queue:is_empty() do
        -- Get current cell
        local s_curr = s_queue:pop()
        local g_curr = g_queue:pop()

        -- Get the four adjacents to the current s cell
        local s_up = {
            x = s_curr.x,
            y = s_curr.y - 1,
            parent = s_curr
        }
        if s_is_free(s_up) then
            table.insert(s_visited, s_up)
            s_queue:push(s_up)
        end

        local s_down = {
            x = s_curr.x,
            y = s_curr.y + 1,
            parent = s_curr
        }
        if s_is_free(s_down) then
            table.insert(s_visited, s_down)
            s_queue:push(s_down)
        end

        local s_left = {
            x = s_curr.x - 1,
            y = s_curr.y,
            parent = s_curr
        }
        if s_is_free(s_left) then
            table.insert(s_visited, s_left)
            s_queue:push(s_left)
        end

        local s_right = {
            x = s_curr.x + 1,
            y = s_curr.y,
            parent = s_curr
        }
        if s_is_free(s_right) then
            table.insert(s_visited, s_right)
            s_queue:push(s_right)
        end

        -- Get the four adjacents to the current g cell
        local g_up = {
            x = g_curr.x,
            y = g_curr.y - 1,
            parent = g_curr
        }
        if g_is_free(g_up) then
            table.insert(g_visited, g_up)
            g_queue:push(g_up)
        end

        local g_down = {
            x = g_curr.x,
            y = g_curr.y + 1,
            parent = g_curr
        }
        if g_is_free(g_down) then
            table.insert(g_visited, g_down)
            g_queue:push(g_down)
        end

        local g_left = {
            x = g_curr.x - 1,
            y = g_curr.y,
            parent = g_curr
        }
        if g_is_free(g_left) then
            table.insert(g_visited, g_left)
            g_queue:push(g_left)
        end

        local g_right = {
            x = g_curr.x + 1,
            y = g_curr.y,
            parent = g_curr
        }
        if g_is_free(g_right) then
            table.insert(g_visited, g_right)
            g_queue:push(g_right)
        end

        -- Check for intersecting node
        -- If intersecting cell is found, that means there is a path.
        if intersect(s_visited, g_visited) then
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
    if BiDirBFS(start, goal) then
        local cell = s_iCell
        while cell.parent do
            spr(PATH, cell.x * 8, cell.y * 8)
            cell = cell.parent
        end
        cell = g_iCell
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
