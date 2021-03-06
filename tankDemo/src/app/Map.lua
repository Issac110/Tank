require "app.Common"

local Map = class("Map")
local Block = require("app.Block")

function Map:ctor(node)

    self.map = {}
    self.node = node

    for x = 0, MapWidth - 1 do
        for y = 0, MapHeight - 1 do
            if x == 0 or x == MapWidth - 1 or y == 0 or y == MapHeight - 1 then
                self:Set(x, y, "steel")
            else
                self:Set(x, y, "mud")
            end
        end
    end

    self:Set(5, 8, "steel")
    self:Set(3, 8, "grass")
    self:Set(7, 8, "brick")
end

function Map:Get(x, y)
    if x < 0 or y < 0 then
        return nil
    end

    if x >= MapWidth or y >= MapHeight then
        return nil
    end

    return self.map[x * MapHeight + y]
end

function Map:Set(x, y, type)
    local block = self.map[x * MapHeight + y]
    if block == nil then
        block = Block.new(self.node)
    end

    block:SetPos(x, y)
    self.map[x * MapHeight + y] = block
    block:Reset(type)
    block.x = x
    block.y = y
end

--给定一个坐标和一个矩形，看是否碰到坐标下的方块
function Map:collideWithBlock(r, x, y)
    local block = self:Get(x, y)

    --超出范围
    if block == nil then
        return nil
    end

    --这个方块可以过去
    if block.damping < 1 then
        return nil
    end

    if RectIntersect(r, block:GetRect()) ~= nil then
        return block
    end

    return nil

end

function Map:Collide(posx, posxy, ex)

    local objRect = NewRect(posx, posxy, ex)

    for x = 0, MapWidth - 1 do
        for y = 0, MapHeight - 1 do
            local b = self:collideWithBlock(objRect, x, y)
            if b ~= nil then
                return b
            end
        end
    end
    return nil
end

--精准碰撞
function Map:Hit(posx,posy)
    local x,y = Pos2Grid(posx,posy)
    local block = self:Get(x,y)

    if block == nil then
        return nil ,true
    end

    if block.breakable then
        return block
    end

    return nil
end

return Map