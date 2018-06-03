
HgePar=class(ClassBase)

function HgePar:ctor()
	self.par=ParticleCreate()
	self.img=false
end

function HgePar:destory()
	if self.par then
		ParticleDelete(self.par)
	end
	if self.img then
		ImageFree(self.img)	
	end
end

function HgePar:loadPsi(filename)
	local buffer,size=PGBufferCreate(filename)
	ParticleSetDeploy(self.par,buffer,size)
	PGBufferDelete(buffer)
end

function HgePar:loadSprite(filename,x,y,w,h)
	self.img=ImageLoad(filename,IMG_8888)
	ParticleSetTexture(self.par,self.img,x,y,w,h)
end

function HgePar:loadPsiFrom(pk,filename)
	local buffer,size=PGBufferCreate(pk,filename)
	ParticleSetDeploy(self.par,buffer,size)
	PGBufferDelete(buffer)
end

function HgePar:loadSpriteFrom(pk,filename,x,y,w,h)
	self.img=ImageLoad(pk,filename,IMG_8888)
	ParticleSetTexture(self.par,self.img,x,y,w,h)
end

function HgePar:update()
	ParticleUpdate(self.par)
end

function HgePar:render()
	ParticleRender(self.par)
end

function HgePar:fire(dx,dy)
	ParticleFire(self.par,dx,dy)
end

function HgePar:stop(bool)
	ParticleStop(self.par,bool)
end

function HgePar:moveto(x,y,bool)
	ParticleMoveTo(self.par,x,y,bool)
end