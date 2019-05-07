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

-- Create Priority Queue
function create_priority_queue()
    local queue = {
        heap = {},
    }

    function queue:push(item)
        -- insert item to the end of heap
        table.insert(self.heap, item)
        self:swim(#self.heap)
    end

    function queue:swim(k)
        local heap = self.heap
        -- Target: k
        -- Parent: k // 2
        while k > 1 do
            local p = k // 2
            if heap[k].dist < heap[p].dist then
                -- swap heap[k] and heap[p]
                local temp = heap[k]
                heap[k] = heap[p]
                heap[p] = temp
                -- continue
                k = p
            else
                break
            end
        end
    end

    function queue:pop()
        if self:is_empty() then
            return nil
        end

        local heap = self.heap

        local min = heap[1]
        heap[1] = heap[#heap]
        -- remove heap[#heap]
        table.remove(heap)
        self:sink(1)
        return min
    end

    function queue:sink(r)
        local heap = self.heap
        -- r: sub-tree root
        -- Left child: 2 * r
        -- Right child: 2 * r + 1
        while 2 * r <= #heap do
            local j = 2 * r
            if j + 1 <= #heap and heap[j + 1].dist < heap[j].dist then
                j = j + 1
            end
            -- compare to r
            if heap[j].dist < heap[r].dist then
                -- swap heap[r] and heap[j]
                local temp = heap[r]
                heap[r] = heap[j]
                heap[j] = temp
                -- continue
                r = j
            else
                break
            end
        end
    end

    function queue:is_empty()
        if #self.heap == 0 then
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

-- Greedy Best First Search
function GBFS(start, goal)
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

    if not is_free(start) then
        return false
    end

    local queue = create_priority_queue()

    table.insert(visited, start)
    queue:push({ cell = start, dist = distance(start) })

    while not queue:is_empty() do
        -- Get best cell
        local curr = (queue:pop()).cell

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
            queue:push({ cell = up, dist = distance(up) })
        end

        local down = {
            x = curr.x,
            y = curr.y + 1,
            parent = curr
        }
        if is_free(down) then
            table.insert(visited, down)
            queue:push({ cell = down, dist = distance(down) })
        end

        local left = {
            x = curr.x - 1,
            y = curr.y,
            parent = curr
        }
        if is_free(left) then
            table.insert(visited, left)
            queue:push({ cell = left, dist = distance(left) })
        end

        local right = {
            x = curr.x + 1,
            y = curr.y,
            parent = curr
        }
        if is_free(right) then
            table.insert(visited, right)
            queue:push({ cell = right, dist = distance(right) })
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
    if GBFS(start, goal) then
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
