CameraShake = 0.65

BulletShapeIndex = 1
MagShapeIndex = 2
TriggerShapeIndex = 3
StrikerShapeIndex = 4
GateShapeIndex = 5
BodyShapeIndex = 6

VoxSize = 0.05

IsShooting = false
ShootingAnimationPosition = 1

Animations = {}

CurrentAnimation = {}

State = "idle"

Animation = {
	animation = {},
	frames = 0,
	current = 0,
	ended = false,
	shapes = nil,
	initialTransforms = nil
}

function init()
	--Register tool and enable it
	RegisterTool("deserteagle", "Desert Eagle", "MOD/vox/deserteagle.vox")
	SetBool("game.tool.deserteagle.enabled", true)

	SetFloat("game.tool.deserteagle.ammo", 15)

	HitSound = LoadSound("MOD/snd/hit.ogg")

	ShootingAnimation = {
		[GateShapeIndex] = {
			nil,
			nil,
			nil,
			nil,
			Vec(0, 0, Voxel(1)),
			Vec(0, 0, Voxel(1)),
			Vec(0, 0, Voxel(1)),
			Vec(0, 0, Voxel(1)),
			Vec(0, 0, Voxel(-0.5)),
			Vec(0, 0, Voxel(-0.5)),
			Vec(0, 0, Voxel(-0.5)),
			Vec(0, 0, Voxel(-0.5)),
			Vec(0, 0, Voxel(-0.5)),
			Vec(0, 0, Voxel(-0.5)),
			Vec(0, 0, Voxel(-0.25)),
			Vec(0, 0, Voxel(-0.25)),
			Vec(0, 0, Voxel(-0.25)),
			Vec(0, 0, Voxel(-0.25)),
		},
		[StrikerShapeIndex] = {
			nil,
			nil,
			nil,
			nil,
			Vec(0, Voxel(0.25), Voxel(-0.25)),
			Vec(0, Voxel(0.25), Voxel(-0.25)),
			Vec(0, Voxel(0.25), Voxel(-0.25)),
			Vec(0, Voxel(0.25), Voxel(-0.25)),
			Vec(0, Voxel(-1), Voxel(1)),
		},
		[TriggerShapeIndex] = {
			Vec(0, 0, Voxel(-0.25)),
			Vec(0, 0, Voxel(-0.25)),
			Vec(0, 0, Voxel(-0.25)),
			Vec(0, 0, Voxel(-0.25)),
		}
	}

	AddAnimation("fire", Animation:new(nil, ShootingAnimation))

	ReloadingAnimation = {
		[GateShapeIndex] = {
			nil,
			nil,
			nil,
			nil,
			Vec(0, 0, Voxel(1)),
			Vec(0, 0, Voxel(1)),
			Vec(0, 0, Voxel(1)),
			Vec(0, 0, Voxel(100)),
			Vec(0, 0, Voxel(-0.5)),
			Vec(0, 0, Voxel(-0.5)),
			Vec(0, 0, Voxel(-0.5)),
			Vec(0, 0, Voxel(-0.5)),
			Vec(0, 0, Voxel(-0.5)),
			Vec(0, 0, Voxel(-0.5)),
			Vec(0, 0, Voxel(-0.25)),
			Vec(0, 0, Voxel(-0.25)),
			Vec(0, 0, Voxel(-0.25)),
			Vec(0, 0, Voxel(-0.25)),
		},
		[StrikerShapeIndex] = {
			nil,
			nil,
			nil,
			nil,
			Vec(0, Voxel(0.25), Voxel(-0.25)),
			Vec(0, Voxel(0.25), Voxel(-0.25)),
			Vec(0, Voxel(0.25), Voxel(-0.25)),
			Vec(0, Voxel(0.25), Voxel(-0.25)),
			Vec(0, Voxel(-1), Voxel(1)),
		},
		[TriggerShapeIndex] = {
			Vec(0, 0, Voxel(-0.25)),
			Vec(0, 0, Voxel(-0.25)),
			Vec(0, 0, Voxel(-0.25)),
			Vec(0, 0, Voxel(-0.25)),
		}
	}

	AddAnimation("reload", Animation:new(nil, ReloadingAnimation))
end

function SetState(state)
	local animation = Animations[State]

	if animation ~= nil then
		-- animation:finish()
		DebugPrint(animation.ended)
	end
	
	State = state
end

function Fire()
	SetState("fire")

	local animation = Animations[State]
	animation:start()

	DebugPrint(animation.ended)

	local cameraTransform = GetCameraTransform()

	local p = TransformToParentPoint(cameraTransform, Vec(Voxel(20), Voxel(-5), Voxel(-10)))
	local d = VecAdd(TransformToParentVec(cameraTransform, Vec(0, 0, Voxel(-5))))
	Shoot(p, d)

	ShakeCamera(CameraShake)

	PlaySound(HitSound)
end

function Reload()
	SetState("reload")

	local animation = Animations[State]
	animation:start()
end

function Voxel(voxel)
	return voxel * VoxSize
end

function SetShapeOffset(shape, offset)
	local shapeTransform = GetShapeLocalTransform(shape)

	local transform = TransformCopy(shapeTransform)
	transform.pos = VecAdd(transform.pos, offset)
	SetShapeLocalTransform(shape, transform)
end

function GetMaxFrames(animationTable)
	local maxFrames = 0

	for k, v in pairs(animationTable) do
		if #v > maxFrames then
			maxFrames = #v
		end
	end

	return maxFrames
end

function AddAnimation(name, animation)
	Animations[name] = animation
end

function Animation:new(o, animationTable)
	local o = {}
	setmetatable(o, { __index = self })

	o.animationTable = animationTable
	o.frames = GetMaxFrames(animationTable)
	o.currentFrame = 1
	o.ended = false
	o.shapes = nil
	o.initialTransforms = {}

	return o
end

function Animation:next()
	if self.shapes == nil then
		return
	end

	if self.currentFrame > self.frames then
		self.currentFrame = 1
		self.ended = true
	end

	if self.ended == false then
		for shapeIndex, animation in pairs(self.animationTable) do
			SetShapeOffset(self.shapes[shapeIndex], animation[self.currentFrame])
		end

		self.currentFrame = self.currentFrame + 1
	end
end

function Animation:registerShapes(shapes) 
	self.shapes = shapes

	for index = 1, #shapes do
		self.initialTransforms[index] = GetShapeLocalTransform(shapes[index])
	end
end

function Animation:resetTransforms()
	if self.initialTransforms == nil then
		return
	end

	for index = 1, #self.initialTransforms do
		SetShapeLocalTransform(self.shapes[index], self.initialTransforms[index])
	end
end

function Animation:start()
	self.resetTransforms(self)
	self.currentFrame = 1
	self.ended = false
end

function Animation:finish()
	self.ended = true
	self.currentFrame = 1
	self.resetTransforms(self)
end

function Animation:foo()
	DebugPrint("HIIIIi")
end


function tick(dt)
	--Check if laser gun is selected
	if GetString("game.player.tool") == "deserteagle" then
		--Shooting
		if InputPressed("usetool") then
			Fire()
		end

		if InputPressed("r") then
			Reload()
		end

		local animation = Animations[State]

		if animation ~= nil then
			if animation.shapes == nil then
				local body = GetToolBody()
				local shapes = GetBodyShapes(body)

				animation:registerShapes(shapes)

				animation:foo()
			end

			animation:next()
		end
	end
end
