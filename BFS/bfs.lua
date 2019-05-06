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

-- BFS
function BFS(start, goal)
    local visited = {}

    -- Check validity
    local function is_free(cell)
        return (not table.contains(visited, cell)
                and not is_wall(cell.x, cell.y))
    end

    if not is_free(start) then
        return false
    end

    local queue = create_queue()

    table.insert(visited, start)
    queue:push(start)
    
    while not queue:is_empty() do
        -- Get current cell
        local curr = queue:pop()

        if equal_pos(curr, goal) then
            goal.parent = curr.parent
            return true
        end

        -- Get the four adjacents to the current cell
        local up = {
            x = curr.x,
            y = curr.y - 1,
            parent = curr
        }
        if is_free(up) then
            table.insert(visited, up)
            queue:push(up)
        end

        local down = {
            x = curr.x,
            y = curr.y + 1,
            parent = curr
        }
        if is_free(down) then
            table.insert(visited, down)
            queue:push(down)
        end

        local left = {
            x = curr.x - 1,
            y = curr.y,
            parent = curr
        }
        if is_free(left) then
            table.insert(visited, left)
            queue:push(left)
        end

        local right = {
            x = curr.x + 1,
            y = curr.y,
            parent = curr
        }
        if is_free(right) then
            table.insert(visited, right)
            queue:push(right)
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
    if BFS(start, goal) then
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
