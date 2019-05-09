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
            found = false,
            dist = INF,
            parent = {
                x = nil,
                y = nil
            }
        }
    end
end

-- Dijkstra's algorithm
function Dijkstra(start, goal)
    -- Initialize maze
    for i = MAP_X_BEGIN, MAP_X_END do
        for j = MAP_Y_BEGIN, MAP_Y_END do
            maze[i][j].found = false
            maze[i][j].dist = INF
            maze[i][j].parent.x = nil
            maze[i][j].parent.y = nil
        end
    end

    -- Find the position of minimum distance
    local function minDistPos()
        local min = INF
        local min_x = nil
        local min_y = nil

        for i = MAP_X_BEGIN, MAP_X_END do
            for j = MAP_Y_BEGIN, MAP_Y_END do
                if not maze[i][j].found and maze[i][j].dist < min then
                    min = maze[i][j].dist
                    min_x = i
                    min_y = j
                end
            end
        end

        return min_x, min_y
    end

    if is_wall(start.x, start.y) then
        return false
    end

    -- Start Search
    maze[start.x][start.y].dist = 0

    for i = 1, CELL_NUM do
        -- Get the position of minimum distance
        local curr_x, curr_y = minDistPos()
        if not curr_x or not curr_y then
            break
        end

        -- Check if it's the goal
        if curr_x == goal.x and curr_y == goal.y then
            return true
        end

        maze[curr_x][curr_y].found = true

        -- Get the four adjacents to the current cell
        local up = {
            x = curr_x,
            y = curr_y - 1
        }
        local down = {
            x = curr_x,
            y = curr_y + 1
        }
        local left = {
            x = curr_x - 1,
            y = curr_y
        }
        local right = {
            x = curr_x + 1,
            y = curr_y
        }

        local adjs = { up, down, left, right }
        for _, adj in ipairs(adjs) do
            if not is_wall(adj.x, adj.y)
               and not maze[adj.x][adj.y].found
               and maze[curr_x][curr_y].dist + 1 < maze[adj.x][adj.y].dist then
                -- Update adj's distance and parent
                maze[adj.x][adj.y].dist = maze[curr_x][curr_y].dist + 1
                maze[adj.x][adj.y].parent.x = curr_x
                maze[adj.x][adj.y].parent.y = curr_y
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
    if Dijkstra(start, goal) then
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
