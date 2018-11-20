require "app.Map"
local Object = require "app.Object"
local SpriteAnim = require "app.SpriteAnim"

local Bullet = class("Bullet", Object)

local function getDeltaByDir(dir, speed)
    if dir == "left" then
        return -speed, 0
    elseif dir == "right" then
        return speed, 0
    elseif dir == "up" then
        return 0, speed
    elseif dir == "down" then
        return 0, -speed
    end

    return 0, 0
end

function Bullet:ctor(node, map, type, obj, dir)
    Bullet.super.ctor(self, node, obj.camp..".bullet")

    self.dx, self.dy = getDeltaByDir(dir, 200)
    self.map = map

    --从发射者身体位置出现
    self.sp:setPositionX(obj.sp:getPositionX())
    self.sp:setPositionY(obj.sp:getPositionY())

    self.spAnim = SpriteAnim.new(self.sp)

    self.spAnim:Define(nil, "bullet", 2, 0.1)
    self.spAnim:Define(nil, "explode", 3, 0.1, true)

    self.spAnim:SetFrame("bullet", type)
end

function Bullet:Update()

    self:UpdatePosition(function(nextPosX, nextPosY)
        local hit
        local block, out = self.map:Hit(nextPosX, nextPosY)

        --有东西或出界
        if block or out then
            hit = "explode"


            --能够被破坏
            if block and block.breakable then

                --需要穿甲弹时，有穿甲弹，没有穿甲弹时才可以被破坏
                if (block.needAP and self.type == 1) or not block.needAP then
                    block:Break()
                end
            end
        else
            local target = self:CheckHit(nextPosX, nextPosY)

            if target then
                target:Destroy()

                if iskindof(target, "Bullet") then
                    hit = "disappear"
                    target.spAnim:Destroy()
                else
                    hit = "explode"
                end
            end
        end

        if hit then
            self:Stop()
            if hit == "explode" then
                self:Explode()
            elseif hit == "disappear" then
                self.spAnim:Destroy()
                self:Destroy()
            end
        end
        return false
    end)
end

function Bullet:Explode()
    self.spAnim:Play("explode", function()
        self:Destroy()
    end)
end

return Bullet