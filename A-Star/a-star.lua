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

-- Infinity
INF = CELL_NUM

-- Initialize start cell and goal cell
start = {
    x = 1,
    y = 1
}

goal = {
    x = 4,
    y = 1
}

-- Who is being controlled?
ctrl = goal

-- Create Priority Queue
function create_priority_queue()
    local queue = {
        heap = {}
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
            if heap[k].f < heap[p].f then
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
            if j + 1 <= #heap and heap[j + 1].f < heap[j].f then
                j = j + 1
            end
            -- compare to r
            if heap[j].f < heap[r].f then
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

-- Check if it's the wall
function is_wall(x, y)
    return mget(x, y) == WALL
end

-- Maze
maze = {}
for i = MAP_X_BEGIN, MAP_X_END do
    maze[i] = {}
    for j = MAP_Y_BEGIN, MAP_Y_END do
        maze[i][j] = {
            -- f = g + h
            g = INF,
            h = INF,
            f = INF,
            open = false,
            closed = false,
            parent = {
                x = nil,
                y = nil
            }
        }
    end
end

-- A* Search
function AStarSearch(start, goal)
    -- Initialize maze
    for i = MAP_X_BEGIN, MAP_X_END do
        for j = MAP_Y_BEGIN, MAP_Y_END do
            maze[i][j].g = INF
            maze[i][j].h = INF
            maze[i][j].f = INF
            maze[i][j].open = false
            maze[i][j].closed = false
            maze[i][j].parent.x = nil
            maze[i][j].parent.y = nil
        end
    end

    -- Manhattan distance between the cell and goal
    local function distance(cell)
        return math.abs(cell.x - goal.x) + math.abs(cell.y - goal.y)
    end

    if is_wall(start.x, start.y) then
        return false
    end

    -- Start Search
    local open_queue = create_priority_queue()

    maze[start.x][start.y].g = 0
    maze[start.x][start.y].h = distance({ x = start.x, y = start.y })
    maze[start.x][start.y].f = maze[start.x][start.y].g + maze[start.x][start.y].h
    maze[start.x][start.y].open = true
    open_queue:push({
        x = start.x,
        y = start.y,
        f = maze[start.x][start.y].f
    })

    while not open_queue:is_empty() do
        local curr = open_queue:pop()
        maze[curr.x][curr.y].open = false
        maze[curr.x][curr.y].closed = true

        -- Check if it's the goal
        if equal_pos(curr, goal) then
            return true
        end

        -- Get the four adjacents to the current cell
        local up = {
            x = curr.x,
            y = curr.y - 1
        }
        local down = {
            x = curr.x,
            y = curr.y + 1
        }
        local left = {
            x = curr.x - 1,
            y = curr.y
        }
        local right = {
            x = curr.x + 1,
            y = curr.y
        }

        local adjs = { up, down, left, right }
        for _, adj in ipairs(adjs) do
            if not is_wall(adj.x, adj.y) and not maze[adj.x][adj.y].closed then
                local new_g = maze[curr.x][curr.y].g + 1
                local new_h = distance({ x = adj.x, y = adj.y })
                local new_f = new_g + new_h
                -- If adj is not open, then open it
                if not maze[adj.x][adj.y].open then
                    maze[adj.x][adj.y].g = new_g
                    maze[adj.x][adj.y].h = new_h
                    maze[adj.x][adj.y].f = new_f
                    maze[adj.x][adj.y].parent.x = curr.x
                    maze[adj.x][adj.y].parent.y = curr.y
                    maze[adj.x][adj.y].open = true
                    open_queue:push({
                        x = adj.x,
                        y = adj.y,
                        f = maze[adj.x][adj.y].f
                    })
                elseif new_f < maze[adj.x][adj.y].f then
                    -- If adj is already open and new_f < old_f,
                    -- then update adj
                    maze[adj.x][adj.y].g = new_g
                    maze[adj.x][adj.y].f = new_f
                    maze[adj.x][adj.y].parent.x = curr.x
                    maze[adj.x][adj.y].parent.y = curr.y
                    -- Place it on open queue
                    open_queue:push({
                        x = adj.x,
                        y = adj.y,
                        f = maze[adj.x][adj.y].f
                    })
                end
            end
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
    if AStarSearch(start, goal) then
        local cell = maze[goal.x][goal.y].parent
        while cell.x and cell.y do
            spr(PATH, cell.x * 8, cell.y * 8)
            cell = maze[cell.x][cell.y].parent
        end
    end

    -- Draw start
    spr(START, start.x * 8, start.y * 8)

    -- Draw goal
    spr(GOAL, goal.x * 8, goal.y * 8)
end
