local Object = require "app.Object"
local SpriteAnim = require "app.SpriteAnim"
local Tank = class("Tank", Object)
local Bullet = require "app.Bullet"

function Tank:ctor(node, name, map, camp)

    Tank.super.ctor(self, node, camp)
    self.node = node
    self.map = map
    --[[临时代码
    local size = cc.Director:getInstance():getWinSize()
    self.sp:setPosition(size.width / 2, size.height / 2)

    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    local frame = spriteFrameCache:getSpriteFrame("tank_green_run0.png")
    self.sp:setSpriteFrame(frame)
    ]]

    self.dx = 0
    self.dy = 0
    self.speed = 100

    self.OnCollide = nil

    self.dir = "up"
    self.spAnim = SpriteAnim.new(self.sp)

    --定义动画
    self.spAnim:Define("run", name, 8, 0.1)
    self.spAnim:SetFrame("run", 0)
end

function Tank:Update()

    self:UpdatePosition(function(nextPosX, nextPosY)
        local hit

        hit = self.map:Collide(nextPosX, nextPosY, -5)

        --活体碰撞
        if hit == nil then
            hit = self:CheckCollide(nextPosX, nextPosY)
        end

        if hit and self.OnCollide then
            self.OnCollide(hit)
        end
        return hit
    end)

end

function Tank:SetDir(dir)

    if dir == nil then
        self.dx = 0
        self.dy = 0
        self.spAnim:Stop("run")
        return
    elseif dir == "left" then
        self.dx = -self.speed
        self.dy = 0
        self.sp:setRotation(-90)
        self.spAnim:Play("run")
    elseif dir == "right" then
        self.dx = self.speed
        self.dy = 0
        self.sp:setRotation(90)
        self.spAnim:Play("run")
    elseif dir == "up" then
        self.dx = 0
        self.dy = self.speed
        self.sp:setRotation(0)
        self.spAnim:Play("run")
    elseif dir == "down" then
        self.dx = 0
        self.dy = -self.speed
        self.sp:setRotation(180)
        self.spAnim:Play("run")
    end

    self.dir = dir
end

function Tank:Destroy()
    self.spAnim:Destroy()
    Tank.super.Destroy(self)
end

function Tank:Fire()
    if self.bullet ~= nil and self.bullet:Alive() then
        return
    end

    self.bullet = Bullet.new(self.node, self.map, 0, self, self.dir)
end

return Tank