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

function init()
	--Register tool and enable it
	RegisterTool("deserteagle", "Desert Eagle", "MOD/vox/deserteagle.vox")
	SetBool("game.tool.deserteagle.enabled", true)

	SetFloat("game.tool.deserteagle.ammo", 15)

	HitSound = LoadSound("MOD/snd/hit.ogg")

	ShootingAnimation = {
		[GateShapeIndex] = {
			Vec(0, 0, Voxel(1)),
			Vec(0, 0, Voxel(1)),
			Vec(0, 0, Voxel(1)),
			Vec(0, 0, Voxel(1)),
			Vec(0, 0, Voxel(-1)),
			Vec(0, 0, Voxel(-1)),
			Vec(0, 0, Voxel(-1)),
			Vec(0, 0, Voxel(-1)),
		}	
	}
end

function Fire()
	IsShooting = true

	ShakeCamera(CameraShake)

	PlaySound(HitSound)
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

function AddAnimation(name, animationTable)
	local frames = GetMaxFrames(animationTable)

	Animations[name] = {
		frames = frames,
		animationTable = animationTable
	}
end

function PlayAnimation(animationName) 

end

function tick(dt)
	--Check if laser gun is selected
	if GetString("game.player.tool") == "deserteagle" then
		--Shooting
		if InputPressed("usetool") then
			Fire()
			DebugPrint(GetMaxFrames(ShootingAnimation))
		end

		if ShootingAnimationPosition > #ShootingAnimation[GateShapeIndex] then
			IsShooting = false
			ShootingAnimationPosition = 1
		end

		if IsShooting == true then 
			local body = GetToolBody()
			local shapes = GetBodyShapes(body)

			SetShapeOffset(shapes[GateShapeIndex], ShootingAnimation[GateShapeIndex][ShootingAnimationPosition])

			ShootingAnimationPosition = ShootingAnimationPosition + 1
		end
	end
end
